# Optional: path to retry list if provided via param
param (
    [string]$RetryList = $null,

    [Parameter(Mandatory = $false)]
    [string]$OU,

    [Parameter(Mandatory = $false)]
    [string]$Identity,

    [Parameter(Mandatory = $false)]
    [string]$Location
)

# Ensure at least one of OU or Identity is provided
if (-not $OU -and -not $Identity) {
    Write-Error "You must specify either -OU or -Identity."
    exit 1
}

# If OU is provided, Location must also be provided
if ($OU -and -not $Location) {
    Write-Error "When using -OU, the -Location parameter is also required. Location would be the Office Prefix (NAS, NJO, SAN, MIA)"
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
if($Location){
    $logPath = "C:\Temp\InstallLogs\GoToAssist_Install_Success-${Location}.log"
    $logSuccess = $logPath  # ensure $logSuccess is initialized

    # Read and deduplicate success log
    $alreadyCompleted = @()
    if (Test-Path $logSuccess) {
        $alreadyCompleted = Get-Content $logSuccess | Where-Object { $_.Trim() -ne "" } | Sort-Object -Unique
        Set-Content -Path $logSuccess -Value $alreadyCompleted
    }
}

# Get list of computers
if ($RetryList -and (Test-Path $RetryList)) {
    $computers = Get-Content $RetryList
} elseif ($OU) {
    $computers = Get-ADComputer -SearchBase "$OU" -Filter {Enabled -eq $True} | Select-Object -ExpandProperty Name
} elseif ($Identity) {
    $computers = @(Get-ADComputer -Identity $Identity | Select-Object -ExpandProperty Name)
} else {
    Write-Error "Unexpected error: no computer source available."
    exit 1
}

Write-Host "Found $($computers.Count) computers to process."

# Filter out computers already completed (only if not Identity-based run)
if ($Location -and -not $Identity) {
    Write-Host "Filtering out already completed installs from log $logSuccess..."
    $computers = $computers | Where-Object { $alreadyCompleted -notcontains $_ }
}

Write-Host "Remaining computers to process: $($computers.Count)"
if ($computers.Count -eq 0) {
    Write-Host "No computers left to process. Exiting."
    exit
}

$i = 0
foreach ($remotePC in $computers) {
    Write-Host "Processing $remotePC..."

    if (!(Test-Connection -ComputerName $remotePC -Count 1 -Quiet)) {
        Write-Warning "$remotePC is unreachable. Skipping. Please check network connectivity."
        continue
    }

    try {
        Write-Host "Copying Installer to $remotePC..."
        Copy-Item -Path $installerSourcePath -Destination "\\$remotePC\C$\Temp\GoToAssist_Remote_Support_Unattended.msi" -Force
        Write-Host "Copy completed successfully."
    } catch {
        Write-Warning "Failed to copy installer to $remotePC. Error: $_"
        continue
    }

    try {
        schtasks /Create /S $remotePC /RU SYSTEM /SC ONCE /TN $taskName /TR $command /ST 17:00 /F | Out-Null
        schtasks /Run /S $remotePC /TN $taskName | Out-Null
        Write-Host "${remotePC}: Install task created and launched."
        if ($logSuccess) {
            Add-Content -Path $logSuccess -Value $remotePC
        }
        $i++
        Write-Host "Successfully processed $i computers so far."
    } catch {
        Write-Warning "Failed to create/run task on $remotePC. Error: $_"
    }
}

if ($i -gt 0) {
    Write-Host "Installation tasks created successfully for $i computers."
} else {
    Write-Warning "No installations were successfully initiated."
}

# Final deduplication of the log file
if ($logSuccess -and (Test-Path $logSuccess)) {
    Write-Host "Deduplicating entries in $logSuccess..."
    $deduped = Get-Content $logSuccess | Where-Object { $_.Trim() -ne "" } | Sort-Object -Unique
    Set-Content -Path $logSuccess -Value $deduped
    Write-Host "Deduplication complete."
}
# End of script