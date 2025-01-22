# Enable system-wide location services
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location -Name Value -Value "Allow"

# Set Time Zone Auto-Update Service to Automatic
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name start -Value "2"

# Check if the Time Zone Auto-Update Service is running, and attempt to start it
$serviceName = "tzautoupdate"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service.Status -ne "Running") {
    try {
        Start-Service -Name $serviceName
        Write-EventLog "Service '$serviceName' was not running and has been started."
    } catch {
        Write-EventLog "Failed to start service '$serviceName'. Error: $_"
    }
} else {
    Write-EventLog "Service '$serviceName' is already running, no action."
}
