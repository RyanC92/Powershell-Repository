<# 
.SYNOPSIS
  Remotely resets Windows Update components by pushing a .BAT and running it via Task Scheduler as SYSTEM, with on-screen + file logging and success/failure summary.

.PARAMETER Identity
  Single computer name to target (e.g., NJOLAP1000).

.PARAMETER ComputersCsv
  Comma-separated list of computer names (e.g., "PC1,PC2,PC3").

.PARAMETER TimeoutSeconds
  Max seconds to wait for each remote task to complete. Default: 300.

.PARAMETER CleanupTask
  Remove the scheduled task from each remote machine after it completes.

.PARAMETER CleanupScript
  Delete the copied .BAT file from each remote machine after it completes.

.PARAMETER OutDir
  Directory to store run logs and CSV results. Default: C:\Temp\RemediationLogs

.OUTPUTS
  Prints per-machine results, writes a CSV to OutDir, and a plaintext run log.

.NOTES
  Requires admin rights to remote machines (SMB admin share + remote Task Scheduler). No 2-minute delay—task is created and triggered immediately.
#>

[CmdletBinding()]
param(
    [Parameter(ParameterSetName='Single', Mandatory=$true)]
    [string]$Identity,

    [Parameter(ParameterSetName='List', Mandatory=$true)]
    [string]$ComputersCsv,

    [int]$TimeoutSeconds = 300,

    [switch]$CleanupTask,
    [switch]$CleanupScript,

    [string]$OutDir = 'C:\Temp\RemediationLogs'
)

# ------------------- Config -------------------
$BatchFileName   = 'ResetWindowsUpdate.bat'
$RemoteBatchPath = "C:\Temp\$BatchFileName"
$LocalStagingDir = 'C:\Temp'
$TaskName        = 'WinUpdateRemediation'
$TaskCommand     = "cmd.exe /c $RemoteBatchPath"
$ServicesToCheck = @('wuauserv','CryptSvc','bits','msiserver')

$BatchContents = @'
@echo off
setlocal enableextensions
set ERR=0

rem Stop services
net stop wuauserv  || set ERR=1
net stop cryptSvc  || set ERR=1
net stop bits      || set ERR=1
net stop msiserver || set ERR=1

rem Delete cache folders
if exist C:\Windows\SoftwareDistribution\Download del /q /s C:\Windows\SoftwareDistribution\Download\*  || set ERR=1
if exist C:\Windows\system32\catroot2 del /q /s C:\Windows\system32\catroot2\*              || set ERR=1

rem Start services
net start wuauserv  || set ERR=1
net start cryptSvc  || set ERR=1
net start bits      || set ERR=1
net start msiserver || set ERR=1

exit /b %ERR%
'@

# ------------------- Setup logging -------------------
if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -Path $OutDir -ItemType Directory -Force | Out-Null }
$RunId    = (Get-Date).ToString('yyyyMMdd-HHmmss')
$CsvPath  = Join-Path $OutDir "WinUpdateRemediation-Results-$RunId.csv"
$LogPath  = Join-Path $OutDir "WinUpdateRemediation-Run-$RunId.log"

function Write-Log {
    param(
        [Parameter(Mandatory)] [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS')] [string]$Level = 'INFO'
    )
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$ts][$Level] $Message"
    Add-Content -Path $LogPath -Value $line
    switch ($Level) {
        'INFO'    { Write-Host $line }
        'WARN'    { Write-Host $line -ForegroundColor Yellow }
        'ERROR'   { Write-Host $line -ForegroundColor Red }
        'SUCCESS' { Write-Host $line -ForegroundColor Green }
    }
}

# ------------------- Helpers -------------------
function Write-StageBatchLocally {
    if (-not (Test-Path -LiteralPath $LocalStagingDir)) {
        New-Item -Path $LocalStagingDir -ItemType Directory -Force | Out-Null
    }
    $localPath = Join-Path $LocalStagingDir $BatchFileName
    Set-Content -Path $localPath -Value $BatchContents -Encoding ASCII -Force
    return $localPath
}

function Ensure-RemoteTemp {
    param([string]$Computer)
    $remoteTemp = "\\$Computer\C$\Temp"
    try {
        if (-not (Test-Path -LiteralPath $remoteTemp)) {
            New-Item -Path $remoteTemp -ItemType Directory -Force | Out-Null
        }
        return $true
    } catch {
        Write-Log "[$Computer] Failed to ensure C$\\Temp. $_" 'WARN'
        return $false
    }
}

function Copy-BatchToRemote {
    param([string]$Computer, [string]$LocalBatchPath)
    try {
        Copy-Item -Path $LocalBatchPath -Destination "\\$Computer\C$\Temp\$BatchFileName" -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Log "[$Computer] Copy failed. $_" 'WARN'
        return $false
    }
}

function New-RemoteTask {
    param([string]$Computer)
    # schtasks requires a time for /SC ONCE; we set it to now and immediately /Run after
    $nowHHmm = (Get-Date).ToString('HH:mm')
    $argsCreate = "/Create /S $Computer /RU SYSTEM /SC ONCE /TN `"$TaskName`" /TR `"$TaskCommand`" /RL HIGHEST /F /ST $nowHHmm"
    $p = Start-Process -FilePath schtasks.exe -ArgumentList $argsCreate -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) {
        Write-Log "[$Computer] schtasks /Create exit code $($p.ExitCode)" 'WARN'
        return $false
    }
    return $true
}

function Start-RemoteTask {
    param([string]$Computer)
    $argsRun = "/Run /S $Computer /TN `"$TaskName`""
    $p = Start-Process -FilePath schtasks.exe -ArgumentList $argsRun -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) {
        Write-Log "[$Computer] schtasks /Run exit code $($p.ExitCode)" 'WARN'
        return $false
    }
    return $true
}

function Get-RemoteTaskInfo {
    param([string]$Computer)
    try {
        $argsQuery = "/Query /S $Computer /TN `"$TaskName`" /V /FO CSV"
        $raw = & schtasks.exe $argsQuery 2>$null
        if (-not $raw) { return $null }
        $rows = $raw | ConvertFrom-Csv
        $row = $rows | Where-Object { $_.'TaskName' -match "\\\\$TaskName$" } | Select-Object -First 1
        return $row
    } catch {
        return $null
    }
}

function Parse-LastResult {
    param([string]$Value)
    if (-not $Value) { return $null }
    $trim = $Value.Trim()
    if ($trim -match '^0x[0-9a-fA-F]+$') {
        return [int]("$trim" -as [uint32])
    }
    if ($trim -match '^[0-9]+$') { return [int]$trim }
    return $null
}

function Wait-RemoteTaskCompletion {
    param(
        [string]$Computer,
        [int]$TimeoutSec = 300
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    do {
        Start-Sleep -Seconds 3
        $info = Get-RemoteTaskInfo -Computer $Computer
        if ($null -eq $info) { continue }
        $status = $info.Status
        if ($status -and $status -ne 'Running') {
            return @{
                Status      = $status
                LastResult  = Parse-LastResult -Value $info.'Last Result'
                LastRunTime = $info.'Last Run Time'
            }
        }
        Write-Progress -Activity "[$Computer] Waiting for task to finish" -Status ($status ? $status : 'Unknown')
    } while ((Get-Date) -lt $deadline)

    return @{ Status = 'Timeout'; LastResult = $null; LastRunTime = $null }
}

function Test-RemoteServicesRunning {
    param([string]$Computer, [string[]]$ServiceNames)
    $allOk = $true
    $details = @{}
    foreach ($svc in $ServiceNames) {
        try {
            $out = sc.exe "\\$Computer" query $svc 2>&1 | Out-String
            $isRunning = ($out -match 'STATE\s*:\s*\d+\s+RUNNING')
            $details[$svc] = $(if ($isRunning) { 'Running' } else { 'NotRunning' })
            if (-not $isRunning) { $allOk = $false }
        } catch {
            $details[$svc] = 'QueryFailed'
            $allOk = $false
        }
    }
    return @{ AllRunning = $allOk; Details = $details }
}

function Remove-RemoteTask { param([string]$Computer) try { & schtasks.exe "/Delete /S $Computer /TN `"$TaskName`" /F" | Out-Null } catch { } }
function Remove-RemoteBatch { param([string]$Computer) try { Remove-Item -Path "\\$Computer\C$\Temp\$BatchFileName" -Force -ErrorAction SilentlyContinue } catch { } }

# ------------------- Target resolution -------------------
$Targets = @()
if ($PSCmdlet.ParameterSetName -eq 'Single') {
    $Targets = @($Identity.Trim()) | Where-Object { $_ }
} else {
    $Targets = ($ComputersCsv -split ',' | ForEach-Object { $_.Trim() }) | Where-Object { $_ } | Sort-Object -Unique
}
if (-not $Targets -or $Targets.Count -eq 0) { Write-Log 'No target computers specified.' 'ERROR'; exit 1 }

# Stage local batch once
$LocalBatchPath = Write-StageBatchLocally
Write-Log "Staged batch at $LocalBatchPath"
Write-Log "Run log: $LogPath"

# ------------------- Execution -------------------
$results = @()
$successCount = 0
$failureCount = 0

Write-Log "Starting remediation on $($Targets.Count) computer(s)..."

foreach ($Computer in $Targets) {
    Write-Log "---- [$Computer] ----"

    if (-not (Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
        Write-Log "[$Computer] Unreachable (ICMP). Skipping." 'WARN'
        $results += [pscustomobject]@{ Computer=$Computer; Reachable=$false; TaskCreated=$false; TaskStarted=$false; TaskStatus=$null; LastResult=$null; ServicesOK=$false; Success=$false; Notes='Unreachable (ping failed)' }
        $failureCount++
        continue
    }

    $notes = New-Object System.Collections.Generic.List[string]

    if (-not (Ensure-RemoteTemp -Computer $Computer)) {
        $results += [pscustomobject]@{ Computer=$Computer; Reachable=$true; TaskCreated=$false; TaskStarted=$false; TaskStatus=$null; LastResult=$null; ServicesOK=$false; Success=$false; Notes='Failed to create/access \\C$\\Temp' }
        $failureCount++
        continue
    }

    if (-not (Copy-BatchToRemote -Computer $Computer -LocalBatchPath $LocalBatchPath)) {
        $results += [pscustomobject]@{ Computer=$Computer; Reachable=$true; TaskCreated=$false; TaskStarted=$false; TaskStatus=$null; LastResult=$null; ServicesOK=$false; Success=$false; Notes='Failed to copy batch file' }
        $failureCount++
        continue
    }

    if (-not (New-RemoteTask -Computer $Computer)) {
        $results += [pscustomobject]@{ Computer=$Computer; Reachable=$true; TaskCreated=$false; TaskStarted=$false; TaskStatus=$null; LastResult=$null; ServicesOK=$false; Success=$false; Notes='Failed to create task' }
        $failureCount++
        continue
    }

    if (-not (Start-RemoteTask -Computer $Computer)) {
        $results += [pscustomobject]@{ Computer=$Computer; Reachable=$true; TaskCreated=$true; TaskStarted=$false; TaskStatus=$null; LastResult=$null; ServicesOK=$false; Success=$false; Notes='Failed to start task' }
        $failureCount++
        if ($CleanupTask)  { Remove-RemoteTask  -Computer $Computer }
        if ($CleanupScript){ Remove-RemoteBatch -Computer $Computer }
        continue
    }

    Start-Sleep -Seconds 2  # give it a moment to transition to Running
    $taskOutcome = Wait-RemoteTaskCompletion -Computer $Computer -TimeoutSec $TimeoutSeconds
    $lastCode    = $taskOutcome.LastResult
    $taskStatus  = $taskOutcome.Status
    if ($taskStatus -eq 'Timeout') { $notes.Add("Task did not finish within ${TimeoutSeconds}s") }

    $svcCheck    = Test-RemoteServicesRunning -Computer $Computer -ServiceNames $ServicesToCheck
    $servicesOK  = [bool]$svcCheck.AllRunning
    if (-not $servicesOK) {
        $bad = ($svcCheck.Details.GetEnumerator() | Where-Object { $_.Value -ne 'Running' } | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; '
        $notes.Add("Services not all running: $bad")
    }

    $isSuccess = ($taskStatus -ne 'Running' -and $taskStatus -ne 'Timeout' -and $lastCode -eq 0 -and $servicesOK)

    if ($isSuccess) { Write-Log "[$Computer] SUCCESS (LastResult=$lastCode, Status=$taskStatus)" 'SUCCESS' }
    else            { Write-Log "[$Computer] FAILURE (LastResult=$lastCode, Status=$taskStatus) | $($notes -join ' | ')" 'ERROR' }

    $results += [pscustomobject]@{
        Computer    = $Computer
        Reachable   = $true
        TaskCreated = $true
        TaskStarted = $true
        TaskStatus  = $taskStatus
        LastResult  = $lastCode
        ServicesOK  = $servicesOK
        Success     = $isSuccess
        Notes       = ($notes -join ' | ')
    }

    if ($isSuccess) { $successCount++ } else { $failureCount++ }

    if ($CleanupTask)  { Remove-RemoteTask  -Computer $Computer }
    if ($CleanupScript){ Remove-RemoteBatch -Computer $Computer }
}

# ------------------- Summary + Save -------------------
Write-Host ""; Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host ("Successful : {0}" -f $successCount) -ForegroundColor Green
Write-Host ("Failed     : {0}" -f $failureCount) -ForegroundColor Red
Write-Host ""

$results | Sort-Object Computer | Tee-Object -Variable Sorted | Format-Table -Auto
$Sorted | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
Write-Log "Saved results CSV to $CsvPath"
Write-Log "Full run log saved to $LogPath"

# Return objects to pipeline (useful for programmatic consumption)
$Sorted
