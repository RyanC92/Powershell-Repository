# Optional: path to retry list if provided via param
param (
    [string]$RetryList = $null,
    [string]$Location = $null,
    [string]$OU = $null
)

if (-not $Location -or $Location -eq "") {
    Write-Warning "Location parameter is required. Please specify a valid location."
    Write-Warning "Valid Parameters are -Location, -OU and -RetryList"
    exit 1
}elseif (-not $OU -or $OU -eq "") {
    Write-Warning "OU parameter is required. Please specify a valid OU."
    Write-Warning "Valid Parameters are -Location, -OU and -RetryList"
    exit 1
}

# Import AD module (only needed once per session)
Import-Module ActiveDirectory

# Define installer and task parameters
$installerSourcePath = "C:\Temp\Installers\GoToAssist_Remote_Support_Unattended.msi"
if (-not (Test-Path $installerSourcePath)) {
    Write-Warning "Installer not found at $installerSourcePath."
    Write-Warning "Please ensure the GoToAssist installer (GoToAssist_Remote_Support_Unattended.msi) is present at this path before running the script."
    exit 1
}
$installerRemotePath = "C:\Temp\GoToAssist_Remote_Support_Unattended.msi"
$taskName = "InstallGoToAssist"
$command = "msiexec /i `"$installerRemotePath`" /qn"

# Output paths
$logSuccess = "C:\Temp\InstallLogs\GoToAssist_Install_Success-${Location}.log"


# Read and deduplicate success log
$alreadyCompleted = @()
if (Test-Path $logSuccess) {
    $alreadyCompleted = Get-Content $logSuccess | Where-Object { $_.Trim() -ne "" } | Sort-Object -Unique
    Set-Content -Path $logSuccess -Value $alreadyCompleted
}

# Get list of computers
if ($RetryList -and (Test-Path $RetryList)) {
    $computers = Get-Content $RetryList
} else {
    $computers = Get-ADComputer -SearchBase "$OU" -Filter {Enabled -eq $True} | Select-Object -ExpandProperty Name
}

Write-Host "Found $($computers.Count) computers to process."

Write-Host "Filtering out already completed installs..."
# Filter out already completed installs
$computers = $computers | Where-Object { $alreadyCompleted -notcontains $_ }

Write-Host "Remaining computers to process: $($computers.Count)"
if ($computers.Count -eq 0) {
    Write-Host "No computers left to process. Exiting."
    exit
}

foreach ($remotePC in $computers) {
    Write-Host "Processing $remotePC..."

    if (!(Test-Connection -ComputerName $remotePC -Count 1 -Quiet)) {
        Write-Warning "$remotePC is unreachable. Skipping. Please check network connectivity."
        continue
    }

    # Copy installer to remote machine
    try {
        Copy-Item -Path $installerSourcePath -Destination "\\$remotePC\C$\Temp\GoToAssist_Remote_Support_Unattended.msi" -Force
    } catch {
        Write-Warning "Failed to copy installer to $remotePC. Error: $_"
        continue
    }

    # Create and run scheduled task
    try {
        schtasks /Create /S $remotePC /RU SYSTEM /SC ONCE /TN $taskName /TR $command /ST 17:00 /F | Out-Null
        schtasks /Run /S $remotePC /TN $taskName | Out-Null
        Write-Host "${remotePC}: Install task created and launched."
        Add-Content -Path $logSuccess -Value $remotePC
    } catch {
        Write-Warning "Failed to create/run task on $remotePC. Error: $_"

    }
}
