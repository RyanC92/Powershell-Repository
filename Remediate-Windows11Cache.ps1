<# 
.SYNOPSIS
  Remotely resets Windows Update components by pushing a .BAT and running it via Task Scheduler as SYSTEM.

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

.OUTPUTS
  Prints per-machine results and a summary of success/failure counts.

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
$BatchFileName = 'ResetWindowsUpdate.bat'
$RemoteBatchPath = "C:\Temp\$BatchFileName"
$LocalStagingDir = 'C:\Temp'
$TaskName = 'WinUpdateRemediation'
$TaskCommand = "cmd.exe /c $RemoteBatchPath"
$ServicesToCheck = @('wuauserv','cryptSvc','bits','msiserver')

# The exact commands you provided, with basic error propagation (non-zero exit on any failure)
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
del /q /s C:\Windows\SoftwareDistribution\Download\*  || set ERR=1
del /q /s C:\Windows\system32\catroot2\*              || set ERR=1

rem Start services
net start wuauserv  || set ERR=1
net start cryptSvc  || set ERR=1
net start bits      || set ERR=1
net start msiserver || set ERR=1

exit /b %ERR%
'@

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
        Write-Warning "[$Computer] Failed to ensure C$\Temp. $_"
        return $false
    }
}

function Copy-BatchToRemote {
    param([string]$Computer, [string]$LocalBatchPath)
    try {
        Copy-Item -Path $LocalBatchPath -Destination "\\$Computer\C$\Temp\$BatchFileName" -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Warning "[$Computer] Copy failed. $_"
        return $false
    }
}

function New-RemoteTask {
    param([string]$Computer)
    # Create (schedule time value is required by schtasks for /SC ONCE, but we trigger immediately via /Run)
    $nowHHmm = (Get-Date).ToString('HH:mm')
    $argsCreate = "/Create /S $Computer /RU SYSTEM /SC ONCE /TN `"$TaskName`" /TR `"$TaskCommand`" /RL HIGHEST /F /ST $nowHHmm"
    $p = Start-Process -FilePath schtasks.exe -ArgumentList $argsCreate -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) {
        Write-Warning "[$Computer] schtasks /Create exit code $($p.ExitCode)"
        return $false
    }
    return $true
}

function Start-RemoteTask {
    param([string]$Computer)
    $argsRun = "/Run /S $Computer /TN `"$TaskName`""
    $p = Start-Process -FilePath schtasks.exe -ArgumentList $argsRun -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) {
        Write-Warning "[$Computer] schtasks /Run exit code $($p.ExitCode)"
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
        # ConvertFrom-Csv needs header row; schtasks includes it
        $rows = $raw | ConvertFrom-Csv
        # Match the row for our task (TaskName is like '\WinUpdateRemediation')
        $row = $rows | Where-Object { $_.'TaskName' -match "\\$TaskName$" } | Select-Object -First 1
        return $row
    } catch {
        return $null
    }
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
        # Status typically "Running" while executing; other values: "Ready", "Queued"
        $status = $info.Status
        if ($status -and $status -ne 'Running') {
            # Return last result when it stops running
            $code = [int]($info.'Last Result' -as [int])
            return @{
                Status       = $status
                LastResult   = $code
                LastRunTime  = $info.'Last Run Time'
            }
        }
    } while ((Get-Date) -lt $deadline)

    return @{
        Status       = 'Timeout'
        LastResult   = $null
        LastRunTime  = $null
    }
}

function Test-RemoteServicesRunning {
    param([string]$Computer, [string[]]$ServiceNames)
    $allOk = $true
    $details = @{}
    foreach ($svc in $ServiceNames) {
        try {
            # Use 'sc' for broad compatibility without relying on PS Remoting
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

function Remove-RemoteTask {
    param([string]$Computer)
    try {
        $argsDel = "/Delete /S $Computer /TN `"$TaskName`" /F"
        & schtasks.exe $argsDel | Out-Null
    } catch { }
}

function Remove-RemoteBatch {
    param([string]$Computer)
    try {
        Remove-Item -Path "\\$Computer\C$\Temp\$BatchFileName" -Force -ErrorAction SilentlyContinue
    } catch { }
}

# ------------------- Target resolution -------------------
$Targets = @()
if ($PSCmdlet.ParameterSetName -eq 'Single') {
    $Targets = @($Identity.Trim()) | Where-Object { $_ }
} else {
    $Targets = ($ComputersCsv -split ',' | ForEach-Object { $_.Trim() }) | Where-Object { $_ } | Sort-Object -Unique
}
if (-not $Targets -or $Targets.Count -eq 0) {
    Write-Error "No target computers specified." ; exit 1
}

# Stage
