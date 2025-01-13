# Ensure the script runs in PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7 or higher." -ForegroundColor Red
    exit
}

# Load necessary modules
Install-ModuleIfNotInstalled -ModuleName "WindowsCompatibility"
Import-WinModule -Name ActiveDirectory
#  Connect to Microsoft Graph
$ImpTenantID = Get-Content "C:\Users\rcurran\OneDrive - Turner Construction\Intune\IntuneTenantID.txt"
Connect-MgGraph -TenantID "$ImpTenantID" -NoWelcome

# Define CSV file path
$CsvFile = "C:\temp\reports\Intune-StaleDeviceID-$([DateTime]::Now.ToString('MM-dd-yyyy-hh.mm')).csv"

# Retrieve AD Organizational Units
$CompOrgUnits = Get-ADOrganizationalUnit -Filter {Name -eq "Computers"} | Select-Object Name, DistinguishedName

# Fetch all AD computer objects in parallel
$ADPC = $CompOrgUnits | ForEach-Object -Parallel {
    Get-ADComputer -SearchBase $_.DistinguishedName -Filter {
        (Enabled -eq $True) -and (Description -notlike "*Server*")
    } | Select-Object Name, ObjectGUID
} -ThrottleLimit 5 # Adjust based on system capabilities

# Parallel comparison of AD devices to Intune devices
$ADPC | ForEach-Object -Parallel {
    param ($CsvFile)

    # Fetch matching Intune devices
    $MSDev = Get-MGDevice -Filter "DisplayName eq '$($PSItem.Name)'" | Select-Object DisplayName, DeviceID

    foreach ($Dev in $MSDev) {
        $CrossMatch = ($Dev.DeviceID -eq $PSItem.ObjectGUID)

        $Result = [PSCustomObject]@{
            "Device Name"     = $PSItem.Name
            "Device GUID"     = $PSItem.ObjectGUID
            "Intune DeviceID" = $Dev.DeviceID
            "Cross Match"     = $CrossMatch
        }

        # Append to CSV
        $Result | Export-Csv -Path $CsvFile -NoTypeInformation -Append
    }
} -ArgumentList $CsvFile -ThrottleLimit 5

Write-Host "Processing complete. Results saved to $CsvFile." -ForegroundColor Green
