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
    $modules = @("WindowsCompatibility", "ActiveDirectory", "ImportExcel")

    foreach ($module in $modules) {
        Install-ModuleIfNotInstalled -ModuleName $module
    }
} else {
    Write-Host "This script only runs in PowerShell 7+."
}

Connect-MgGraph -TenantID 20e27700-b670-4553-a27c-d8e2583b3289 -NoWelcome

$excelFile = "C:\temp\reports\Intune-StaleDeviceID-$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"

$ADPC = @()
$Matches = @()
$Inconsistencies = @()
#Pull the entire list of AD Computer Objects
$CompOrgUnits = Get-ADOrganizationalUnit -Filter {Name -eq "Computers"} | select Name, DistinguishedName, ObjectClass

#Building hostname list
Foreach($Org in $CompOrgUnits){
    $ADPC += Get-Adcomputer -Searchbase "$($Org.Distinguishedname)" -Filter {(Enabled -eq $True) -and (Description -notlike "*Server*")} | Select Name, ObjectGUID
}

#Loop through AD hostnames to match up to the Intune hostnames, If the Device ID equals the ObjectGUID, Add the Details to the $Matches Array
#If DeviceID does not match ObjectGUID Add the values to the $Inconsistencies array. 
Foreach ($PC in $ADPC){
    $MSDev = Get-MGdevice -Filter "DisplayName eq '$($PC.Name)'" | select DisplayName, DeviceID
    
    Foreach ($Dev in $MSDev){
        If($Dev.DeviceID -eq $PC.ObjectGUID){
            Write-Host "Device $($PC.Name) with GUID $($PC.ObjectGUID) matches a DeviceID $($Dev.DeviceID) in Intune."
            $Matches += @(
                @{
                    "Device Name" = $PC.Name
                    "Device GUID" = $PC.ObjectGUID
                    "Intune DeviceID" = $Dev.DeviceID
                }
            )
        }elseif($Dev.DeviceID -ne $PC.ObjectGUID){
            Write-Host "Device $($PC.Name) with GUID $($PC.ObjectGUID) does not match a DeviceID $($Dev.DeviceID) in Intune."
            $Inconsitencies += @(
                @{
                    "Device Name" = $PC.Name
                    "Device GUID" = $PC.ObjectGUID
                    "Intune DeviceID" = $Dev.DeviceID
                }
            
            )
        }
    }
}

#Export results to spreadsheet.
$Matches | Export-CSV $excelFile -Append -NoTypeInformation
$Inconsistencies | Export-CSV $excelFile -NoTypeInformation

}  

# $Matches | Export-Excel -Path $excelFile `
#     -AutoSize `
#     -AutoFilter `
#     -BoldTopRow `
#     -FreezeTopRow `
#     -TableStyle 'Medium6' `
#     -Title "Intune Stale DeviceID Report" `
#     -WorksheetName "Matches" `
#     -TitleBold

# $Inconsistencies | Export-Excel -Path $excelFile `
#     -AutoSize `
#     -AutoFilter `
#     -BoldTopRow `
#     -FreezeTopRow `
#     -TableStyle 'Medium6' `
#     -Title "Intune Stale DeviceID Report" `
#     -WorksheetName "Inconsistencies" `
#     -TitleBold