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

    Connect-MgGraph -TenantID 20e27700-b670-4553-a27c-d8e2583b3289 -NoWelcome

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

    # Loop through AD hostnames to match up to the Intune hostnames in parallel
    $ADPC | ForEach-Object -Parallel {
        param (
            $PC,           # Each computer object from AD
            $CsvFilePath   # CSV file path to store results
        )

        # Import the Microsoft Graph module in each parallel run
        Import-Module Microsoft.Graph

        # Retrieve the matching Intune device for each AD computer
        $MSDev = Get-MGDevice -Filter "DisplayName eq '$($PC.Name)'" | Select DisplayName, DeviceID

        foreach ($Dev in $MSDev) {
            $matchEntry = [PSCustomObject]@{
                "Device Name"     = $PC.Name
                "Device GUID"     = $PC.ObjectGUID
                "Intune DeviceID" = $Dev.DeviceID
                "Cross Match"     = ($Dev.DeviceID -eq $PC.ObjectGUID)
            }

            # Export results to the CSV file
            $matchEntry | Export-Csv -Path $CsvFilePath -NoTypeInformation -Append
        }
    } -ArgumentList $_, $CsvFile
}
