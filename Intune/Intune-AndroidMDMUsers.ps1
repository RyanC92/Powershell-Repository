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

        # Load ActiveDirectory
        if (-not (Get-Module -Name ActiveDirectory)) {
            Write-Host "Loading ActiveDirectory module"
            Import-Module -Name ActiveDirectory
        }
    } else {
        Write-Host "This script only runs in PowerShell 7+."
    }
    $ImpTenantID = Get-Content "C:\Users\rcurran\OneDrive - Turner Construction\Intune\IntuneTenantID.txt"
    Connect-MgGraph -TenantID "$ImpTenantID" -NoWelcome


# Retrieve the object ID of the group named 'TUR.ALL.MDM.USERS'
$groupId = (Get-MgGroup -Filter "displayName eq 'TUR.ALL.MDM.USERS'").Id

# Get all members of the specified group and extract their object IDs
$groupMembers = Get-MgGroupMember -GroupId $groupId -All | Select-Object -ExpandProperty Id

# Retrieve all managed devices that run the Android operating system
$androidDevices = Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Android'" -All

# Extract detailed user-related information from each Android device
$androidUserDetails = foreach ($device in $androidDevices) {
    [PSCustomObject]@{
        UserId = $device.UserId                       # ID of the user assigned to the device
        UserPrincipalName = $device.UserPrincipalName # User's principal name (email/UPN)
        DeviceName = $device.DeviceName               # Name of the Android device
        OS = $device.OperatingSystem                  # Operating system (should be Android)
        ComplianceState = $device.ComplianceState     # Compliance state of the device
    }
}

# Initialize arrays to categorize users based on group membership
$inGroup = @()       # Users in the group with Android devices
$notInGroup = @()    # Users NOT in the group but with Android devices

# Classify users into the appropriate array based on group membership
foreach ($user in $androidUserDetails) {
    if ($groupMembers -contains $user.UserId) {
        $inGroup += $user
    } else {
        $notInGroup += $user
    }
}

# Generate a timestamp for uniquely naming the output files
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Export both user groups to separate CSV files with descriptive filenames
$inGroup | Export-Csv -Path "AndroidUsers_InGroup_$timestamp.csv" -NoTypeInformation
$notInGroup | Export-Csv -Path "AndroidUsers_NotInGroup_$timestamp.csv" -NoTypeInformation

# Display the output file names to the console
Write-Host "Reports generated:`n - AndroidUsers_InGroup_$timestamp.csv`n - AndroidUsers_NotInGroup_$timestamp.csv"
}