# Enable system-wide location services
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location -Name Value -Value "Allow"

# Set Time Zone Auto-Update Service to Automatic
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name start -Value "2"

# Define the service name and event log source
$serviceName = "tzautoupdate"
$eventSource = "CustomScriptLog"
$eventLogName = "Application"

# Ensure the event source exists
if (-not (Get-EventLog -LogName $eventLogName -Source $eventSource -ErrorAction SilentlyContinue)) {
    New-EventLog -LogName $eventLogName -Source $eventSource
}

# Check if the Time Zone Auto-Update Service is running, and attempt to start it
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service.Status -ne "Running") {
    try {
        Start-Service -Name $serviceName
        Write-EventLog -LogName $eventLogName -Source $eventSource -EventId 1001 -EntryType Information -Message "Service '$serviceName' was not running and has been started successfully."
    } catch {
        Write-EventLog -LogName $eventLogName -Source $eventSource -EventId 1002 -EntryType Error -Message "Failed to start service '$serviceName'. Error: $_"
    }
} else {
    Write-EventLog -LogName $eventLogName -Source $eventSource -EventId 1003 -EntryType Information -Message "Service '$serviceName' is already running. No action was necessary."
}
