# Function to check if the script is running as Administrator
Measure-Command {
    function Test-Admin {
        return ([bool]([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    }

    # Function to restart the script with elevated privileges if not running as Admin
    function Elevate-Script {
        if (-not (Test-Admin)) {
            $arguments = "& '" + $myinvocation.mycommand.definition + "'"
            Start-Process powershell -ArgumentList $arguments -Verb RunAs
            exit
        }
    }

    # Function to install a module if it is not installed
    function Install-ModuleIfNotInstalled {
        param (
            [string]$ModuleName
        )
        if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Host "Installing module $ModuleName"
            Install-Module -Name $ModuleName -Force -Confirm:$false
        } else {
            Write-Host "Module $ModuleName is already installed"
        }
    }

    # Main script execution
    Elevate-Script

    # Check if running in PowerShell 7+
    $PSVersion = $PSVersionTable.PSVersion.Major
    if ($PSVersion -ge 7) {
        # List of required modules
        $modules = @("WindowsCompatibility")

        foreach ($module in $modules) {
            Install-ModuleIfNotInstalled -ModuleName $module
        }

        # Load ActiveDirectory using WindowsCompatibility
        if (-not (Get-Module -Name ActiveDirectory)) {
            Write-Host "Loading ActiveDirectory module using WindowsCompatibility"
            Import-WinModule -Name ActiveDirectory
        }
    } else {
        Write-Host "This script only runs in PowerShell 7+."
    }
    $ImpTenantID = Get-Content "C:\Users\rcurran\OneDrive - Turner Construction\Intune\IntuneTenantID.txt"
    Connect-MgGraph -TenantID "$ImpTenantID" -NoWelcome

    # Define the CSV file paths
    $CsvFile = "C:\temp\reports\Intune-StaleDeviceID-$([DateTime]::Now.ToString('MM-dd-yyyy-hh.mm')).csv"

    $ADPC = @()
    # Pull the entire list of AD Computer Objects
    $CompOrgUnits = Get-ADOrganizationalUnit -Filter {Name -eq "Computers"} | select Name, DistinguishedName, ObjectClass

    # Building hostname list
    foreach ($Org in $CompOrgUnits) {
        $ADPC += Get-ADComputer -SearchBase "$($Org.DistinguishedName)" -Filter {(Enabled -eq $True) -and (Description -notlike "*Server*")} | Select Name, ObjectGUID
    }

    # Initialize arrays for matches and inconsistencies
    $Results = @()
    $i = 0
    # Loop through AD hostnames to match up to the Intune hostnames
    foreach ($PC in $ADPC) {
        $matchEntry = @()
        $i++
        $MSDev = Get-MGDevice -Filter "DisplayName eq '$($PC.Name)'" | Select DisplayName, DeviceID
        foreach ($Dev in $MSDev) {
            if ($Dev.DeviceID -eq $PC.ObjectGUID) {
                Write-Host "$i. Device $($PC.Name) with GUID $($PC.ObjectGUID) matches a DeviceID $($Dev.DeviceID) in Intune." -ForegroundColor Green
                
                # Create a PSCustomObject to export properly with Cross Match as $True
                $matchEntry = [PSCustomObject]@{
                    "Device Name"     = $PC.Name
                    "Device GUID"     = $PC.ObjectGUID
                    "Intune DeviceID" = $Dev.DeviceID
                    "Cross Match"     = $True
                }
                # Add to CSVFile
                $matchEntry | Export-csv $CsvFile -NoTypeinformation -Append
            } elseif ($Dev.DeviceID -ne $PC.ObjectGUID) {
                Write-Host "$i. Device $($PC.Name) with GUID $($PC.ObjectGUID) does not match a DeviceID $($Dev.DeviceID) in Intune." -ForegroundColor Red
                
                # Create a PSCustomObject to export properly with Cross Match as $False
                $matchEntry = [PSCustomObject]@{
                    "Device Name"     = $PC.Name
                    "Device GUID"     = $PC.ObjectGUID
                    "Intune DeviceID" = $Dev.DeviceID
                    "Cross Match"     = $False
                }

                # Add to CSVFile
                $matchEntry | Export-csv $CsvFile -NoTypeinformation -Append
            }
        }
    }
}