# Ensure the script runs in PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7 or higher." -ForegroundColor Red
    exit
}

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

Elevate-Script

# Load necessary modules
Install-ModuleIfNotInstalled -ModuleName "WindowsCompatibility"
Install-ModuleIfNotInstalled -ModuleName "Microsoft.Graph"

Import-WinModule -Name ActiveDirectory
#  Connect to Microsoft Graph
$ImpTenantID = Get-Content "C:\Users\rcurran\OneDrive - Turner Construction\Intune\IntuneTenantID.txt"
Connect-MgGraph -TenantID "$ImpTenantID" -NoWelcome

# Define CSV file path

$CsvFile = "C:\temp\reports\Intune-StaleDeviceID-$([DateTime]::Now.ToString('MM-dd-yyyy-hh.mm')).csv"

# Retrieve AD Organizational Units
$CompOrgUnits = Get-ADOrganizationalUnit -Filter {Name -eq "Computers"} | Select-Object Name, DistinguishedName

# Fetch all AD computer objects in parallel
$ADPC = $CompOrgUnits | ForEach-Object {
    Get-ADComputer -SearchBase $_.DistinguishedName -Filter {
        (Enabled -eq $True) -and (Description -notlike "*Server*")
    } | Select-Object Name, ObjectGUID
}

Foreach-object -Parallel ($PC in $ADPC){

    $MSDev = Get-MGDevice -Filter "DisplayName eq '$($PC.Name)'" | Select-Object DisplayName, DeviceID

    foreach ($Dev in $MSDev) {
        $CrossMatch = ($Dev.DeviceID -eq $PC.ObjectGUID)

        $Result = [PSCustomObject]@{
            "Device Name"     = $PC.Name
            "Device GUID"     = $PC.ObjectGUID
            "Intune DeviceID" = $Dev.DeviceID
            "Cross Match"     = $CrossMatch
        }

        # Append to CSV
        $Result | Export-Csv -Path $CsvFile -NoTypeInformation -Append
    }
}

}