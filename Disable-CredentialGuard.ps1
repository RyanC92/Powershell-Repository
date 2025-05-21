# Real registry update function with logging
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value,
        [string]$Description
    )

    if (-not (Test-Path $Path)) {
        $message = "$Description path does not exist: $Path. Key will not be created automatically."
        Write-EventLog -LogName Application -Source "CredentialGuardScript" -EntryType Warning -EventId 1004 -Message $message
        Write-Host $message -ForegroundColor DarkYellow
        return
    }

    try {
        $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
        if ($currentValue -eq $Value) {
            $message = "$Description already set to $Value in registry path: $Path"
            Write-EventLog -LogName Application -Source "CredentialGuardScript" -EntryType Information -EventId 1003 -Message $message
            Write-Host $message -ForegroundColor Cyan
        } else {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
            $message = "$Description updated to $Value in registry path: $Path"
            Write-EventLog -LogName Application -Source "CredentialGuardScript" -EntryType Information -EventId 1000 -Message $message
            Write-Host $message -ForegroundColor Green
        }
    } catch {
        $errorMsg = "$Description failed to update in registry path: $Path. Error: $($_.Exception.Message)"
        Write-EventLog -LogName Application -Source "CredentialGuardScript" -EntryType Error -EventId 1001 -Message $errorMsg
        Write-Host $errorMsg -ForegroundColor Red
    }
}

# Ensure the event source exists
if (-not [System.Diagnostics.EventLog]::SourceExists("CredentialGuardScript")) {
    New-EventLog -LogName Application -Source "CredentialGuardScript"
}

# Apply registry changes
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 0 -Description "Credential Guard (SYSTEM)"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" -Name "LsaCfgFlags" -Value 0 -Description "Credential Guard (SOFTWARE)"
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -Description "Virtualization-based Security"

# Final restart notification
$restartMsg = "Credential Guard settings have been updated or confirmed. A restart is required for changes to take effect."
Write-EventLog -LogName Application -Source "CredentialGuardScript" -EntryType Information -EventId 1002 -Message $restartMsg
Write-Host $restartMsg -ForegroundColor Yellow
