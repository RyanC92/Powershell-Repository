# Define registry paths to check
$registryPaths = @(
    @{ Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions"; Name = "value"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name = "AllowDomainPINLogon"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"; Name = "AllowDomainPINLogon"; ExpectedValue = 0 }
)

$biometricPaths = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics"; Name = "Enabled"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures"; Name = "Enabled"; ExpectedValue = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\Fingerprint"; Name = "Enabled"; ExpectedValue = 0 }
)

$remediationNeeded = $false

# Check registry settings
foreach ($reg in ($registryPaths + $biometricPaths)) {
    if (Test-Path $reg.Path) {
        $currentValue = (Get-ItemProperty -Path $reg.Path -Name $reg.Name -ErrorAction SilentlyContinue).$($reg.Name)
        if ($currentValue -ne $reg.ExpectedValue) {
            $remediationNeeded = $true
        }
    } else {
        $remediationNeeded = $true
    }
}

# Check if Windows Hello PIN folder still exists
$ngcFolderPath = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC"
if (Test-Path $ngcFolderPath) {
    $remediationNeeded = $true
}

# Exit codes for Intune Remediation
if ($remediationNeeded) {
    Write-Host "Windows Hello for Business settings are incorrect. Remediation required."
    exit 1
} else {
`
}
