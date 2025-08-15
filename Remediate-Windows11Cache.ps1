<# 
.SYNOPSIS
  Remotely resets Windows Update components by pushing a .BAT and running it via Task Scheduler as SYSTEM, with immediate and final results.

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

.NOTES
  Requires admin rights to remote machines (SMB admin share + remote Task Scheduler).
#>

[CmdletBinding()]
param(
    [Parameter(ParameterSetName='Single', Mandatory=$true)]
    [string]$Identity,

    [Parameter(ParameterSetName='List', Mandatory=$true)]
    [string]$ComputersCsv,

    [int]$TimeoutSeconds = 300,

    [switch]$CleanupTask,
    [switch]$CleanupScript
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

net stop wuauserv  || set ERR=1
net stop cryptSvc  || set ERR=1
net stop bits      || set ERR=1
net stop msiserver || set ERR=1

if exist C:\Windows\SoftwareDistribution\Download del /q /s C:\Windows\SoftwareDistribution\Download\*  || set ERR=1
if exist C:\Windows\system32\catroot2 del /q /s C:\Windows\system32\catroot2\*                          || set ERR=1

net start wuauserv  || set ERR=1
net start cryptSvc  || set ERR=1
net start bits      || set ERR=1
net start msiserver || set ERR=1

exit /b %ERR%
'@

# ------------------- Logging -------------------
$OutDir = 'C:\Temp\RemediationLogs'
if (-not (Test-Path $OutDir)) { New-Item -Path $OutDir -ItemType Directory -Force | Out-Null }
$RunId    = (Get-Date).ToString('yyyyMMdd-HHmmss')
$CsvPath  = Join-Path $OutDir "Results-$RunId.csv"
$LogPath  = Join-Path $OutDir "RunLog-$RunId.txt"

function Write-Log {
    param(
        [string]$Message,
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
    if (-not (Test-Path $LocalStagingDir)) {
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
        if (-not (Test-Path $remoteTemp)) {
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
        Write-Log "[$Computer] Failed to copy batch file. $_" 'WARN'
        return $false
    }
}

function New-RemoteTask {
    param([string]$Computer)
    $startTime = (Get-Date).AddMinutes(1).ToString('HH:mm')
    $argsCreate = "/Create /S $Computer /RU SYSTEM /SC ONCE /TN `"$TaskName`" /TR `"$TaskCommand`" /RL HIGHEST /F /ST $startTime"
    $p = Start-Process schtasks.exe -ArgumentList $argsCreate -NoNewWindow -PassThru -Wait
    return ($p.ExitCode -eq 0)
}

function Start-RemoteTask {
    param([string]$Computer)
    $argsRun = "/Run /S $Computer /TN `"$TaskName`""
    $p = Start-Process schtasks.exe -ArgumentList $argsRun -NoNewWindow -PassThru -Wait
    return ($p.ExitCode -eq 0)
}

function Get-RemoteTaskInfo {
    param([string]$Computer)
    try {
        $argsQuery = "/Query /S $Computer /TN `"$TaskName`" /V /FO CSV"
        $raw = & schtasks.exe $argsQuery 2>$null
        if (-not $raw) { return $null }
        $rows = $raw | ConvertFrom-Csv
        $rows | Where-Object { $_.'TaskName' -match "\\$TaskName$" } | Select-Object -First 1
    } catch { return $null }
}

function Parse-LastResult {
    param([string]$Value)
    if (-not $Value) { return $null }
    $trim = $Value.Trim()
    if ($trim -match '^0x[0-9a-fA-F]+$') { return [int]( "$trim" -as [uint32] ) }
    if ($trim -match '^[0-9]+$') { return [int]$trim }
    return $null
}

function Wait-RemoteTaskCompletion {
    param([string]$Computer, [int]$TimeoutSec = 300)
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
        $progressStatus = if ($status) { $status } else { 'Unknown' }
        Write-Progress -Activity ("[$Computer] Waiting for task to finish") -Status $progressStatus
    } while ((Get-Date) -lt $deadline)
    return @{ Status = 'Timeout'; LastResult = $null; LastRunTime = $null }
}

function Test-RemoteServicesRunning {
    param([string]$Computer, [string[]]$ServiceNames)
    $allOk = $true
    $details = @{}
    foreach ($svc in $ServiceNames) {
        $out = sc.exe "\\$Computer" query $svc 2>&1 | Out-String
        $isRunning = ($out -match 'STATE\s*:\s*\d+\s+RUNNING')
        $details[$svc] = if ($isRunning) { 'Running' } else { 'NotRunning' }
        if (-not $isRunning) { $allOk = $false }
    }
    return @{ AllRunning = $allOk; Details = $details }
}

function Remove-RemoteTask { param([string]$Computer) try { & schtasks.exe "/Delete /S $Computer /TN `"$TaskName`" /F" | Out-Null } catch { } }
function Remove-RemoteBatch { param([string]$Computer) try { Remove-Item "\\$Computer\C$\Temp\$BatchFileName" -Force -ErrorAction SilentlyContinue } catch { } }

# ------------------- Targets -------------------
$Targets = if ($PSCmdlet.ParameterSetName -eq 'Single') {
    @($Identity.Trim())
} else {
    ($ComputersCsv -split ',' | ForEach-Object { $_.Trim() }) | Sort-Object -Unique
}

$LocalBatchPath = Write-StageBatchLocally
Write-Log ("Staged batch at {0}" -f $LocalBatchPath)

# ------------------- Execution -------------------
$results = @()
$successCount = 0
$failureCount = 0

foreach ($Computer in $Targets) {
    Write-Log ("---- [{0}] ----" -f $Computer)

    if (-not (Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
        Write-Log ("{0} unreachable (ping failed)" -f $Computer) 'WARN'
        $results += [pscustomobject]@{Computer=$Computer;Success=$false;Notes='Unreachable'}
        $failureCount++
        continue
    }

    if (-not (Ensure-RemoteTemp $Computer)) { $failureCount++; continue }
    if (-not (Copy-BatchToRemote $Computer $LocalBatchPath)) { $failureCount++; continue }
    if (-not (New-RemoteTask $Computer)) { Write-Log ("{0} failed to create task" -f $Computer) 'ERROR'; $failureCount++; continue }
    if (-not (Start-RemoteTask $Computer)) { Write-Log ("{0} failed to start task" -f $Computer) 'ERROR'; $failureCount++; continue }

    Write-Log ("{0}: Attempted to run the scheduled task" -f $Computer)

    $taskOutcome = Wait-RemoteTaskCompletion $Computer -TimeoutSec $TimeoutSeconds
    $svcCheck = Test-RemoteServicesRunning $Computer $ServicesToCheck

    $isSuccess = ($taskOutcome.Status -ne 'Running' -and $taskOutcome.Status -ne 'Timeout' -and $taskOutcome.LastResult -eq 0 -and $svcCheck.AllRunning)
    if ($isSuccess) {
        Write-Log ("{0}: SUCCESS - ExitCode 0, all services running" -f $Computer) 'SUCCESS'
        $successCount++
    } else {
        Write-Log ("{0}: FAILURE - Status {1}, ExitCode {2}" -f $Computer,$taskOutcome.Status,$taskOutcome.LastResult) 'ERROR'
        $failureCount++
    }

    $results += [pscustomobject]@{
        Computer    = $Computer
        TaskStatus  = $taskOutcome.Status
        ExitCode    = $taskOutcome.LastResult
        ServicesOK  = $svcCheck.AllRunning
        Success     = $isSuccess
    }

    if ($CleanupTask)  { Remove-RemoteTask $Computer }
    if ($CleanupScript){ Remove-RemoteBatch $Computer }
}

# ------------------- Summary -------------------
Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host ("Successful : {0}" -f $successCount) -ForegroundColor Green
Write-Host ("Failed     : {0}" -f $failureCount) -ForegroundColor Red
Write-Host ""

$results | Sort-Object Computer | Tee-Object -Variable Sorted | Format-Table -Auto
$Sorted | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
Write-Log ("Saved results CSV to {0}" -f $CsvPath)
Write-Log ("Full run log saved to {0}" -f $LogPath)

$Sorted
