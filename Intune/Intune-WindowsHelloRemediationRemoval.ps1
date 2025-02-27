#Requires -RunAsAdministrator

# Define Event Log Source
$EventSource = "IntuneWindowsHelloRemoval"
$EventLogName = "Application"

# Ensure the event source exists
if (!(Get-EventLog -LogName $EventLogName -Source $EventSource -ErrorAction SilentlyContinue)) {
    New-EventLog -LogName $EventLogName -Source $EventSource
}

# Function to log events
function Write-Log {
    param (
        [string]$Message,
        [string]$EventType = "Information"
    )
    Write-Host $Message
    Write-EventLog -LogName $EventLogName -Source $EventSource -EntryType $EventType -EventId 1001 -Message $Message
}

Write-Log "Starting Windows Hello for Business removal process..."

# Step 1: Disable Windows Hello for Business via Registry
$RegistryChanges = $false

$registryPaths = @(
    @{ Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions"; Name = "value"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name = "AllowDomainPINLogon"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"; Name = "AllowDomainPINLogon"; ExpectedValue = 0 }
)

foreach ($reg in $registryPaths) {
    if (Test-Path $reg.Path) {
        $currentValue = (Get-ItemProperty -Path $reg.Path -Name $reg.Name -ErrorAction SilentlyContinue).$($reg.Name)
        if ($currentValue -ne $reg.ExpectedValue) {
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.ExpectedValue
            Write-Log "Updated registry: $($reg.Path)\$($reg.Name) to $($reg.ExpectedValue)" -EventType "Information"
            $RegistryChanges = $true
        }
    } else {
        New-Item -Path $reg.Path -Force | Out-Null
        New-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.ExpectedValue -PropertyType DWord -Force | Out-Null
        Write-Log "Created and set registry: $($reg.Path)\$($reg.Name) to $($reg.ExpectedValue)" -EventType "Information"
        $RegistryChanges = $true
    }
}

# Step 2: Remove Windows Hello PIN for all users
$ngcFolderPath = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC"
if (Test-Path $ngcFolderPath) {
    Write-Log "Removing Windows Hello PIN folder..."
    Takeown /f $ngcFolderPath /r /d y | Out-Null
    Icacls $ngcFolderPath /grant administrators:F /t | Out-Null
    Remove-Item -Path $ngcFolderPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $ngcFolderPath -ItemType Directory | Out-Null
    Icacls $ngcFolderPath /reset /t | Out-Null
    Write-Log "Windows Hello PIN credentials removed." -EventType "Information"
} else {
    Write-Log "Windows Hello PIN folder not found, skipping removal." -EventType "Information"
}

# Step 3: Disable Biometric Authentication
$biometricPaths = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics"; Name = "Enabled"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures"; Name = "Enabled"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\Fingerprint"; Name = "Enabled"; ExpectedValue = 0 }
)

foreach ($reg in $biometricPaths) {
    if (Test-Path $reg.Path) {
        $currentValue = (Get-ItemProperty -Path $reg.Path -Name $reg.Name -ErrorAction SilentlyContinue).$($reg.Name)
        if ($currentValue -ne $reg.ExpectedValue) {
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.ExpectedValue
            Write-Log "Updated registry: $($reg.Path)\$($reg.Name) to $($reg.ExpectedValue)" -EventType "Information"
            $RegistryChanges = $true
        }
    } else {
        New-Item -Path $reg.Path -Force | Out-Null
        New-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.ExpectedValue -PropertyType DWord -Force | Out-Null
        Write-Log "Created and set registry: $($reg.Path)\$($reg.Name) to $($reg.ExpectedValue)" -EventType "Information"
        $RegistryChanges = $true
    }
}

# Step 4: Restart Windows Biometric Service if changes were made
if ($RegistryChanges) {
    Write-Log "Restarting Windows Biometric Service..."
    Stop-Service -Name "WbioSrvc" -Force -ErrorAction SilentlyContinue
    Start-Service -Name "WbioSrvc" -ErrorAction SilentlyContinue
    Write-Log "Windows Biometric Service restarted successfully." -EventType "Information"
} else {
    Write-Log "No registry changes detected. Windows Biometric Service restart not required." -EventType "Information"
}

Write-Log "Windows Hello authentication removal completed successfully."
exit 0
