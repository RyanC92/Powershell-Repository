<#
.SYNOPSIS
    Recover deleted computer and BitLocker recovery objects from AD.

.DESCRIPTION
    This script prompts for a hostname, searches for deleted AD computer and BitLocker recovery objects,
    allows the user to select from a list, and restores the selected items.

.NOTES
    Author: Ryan Curran
    Created: 2025-04-22
    Version: 1.0
    Requirements: Active Directory module, AD Recycle Bin enabled
#>

#region Prerequisites
Import-Module ActiveDirectory -ErrorAction Stop
#endregion

#region Functions
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Get-DeletedObjectsByHostname {
    param (
        [string]$hostname
    )

    Write-Log "Searching for deleted objects matching hostname '$hostname'..."
    $filter = "Name -like '*$hostname*'"
    $deletedObjects = Get-ADObject -Filter $filter -IncludeDeletedObjects -Properties *
    $deletedObjects | Where-Object { $_.ObjectClass -in 'computer', 'msFVE-RecoveryInformation' }
}
#endregion

#region Main Logic
try {
    $hostname = Read-Host "Enter the hostname of the deleted device"

    $objects = Get-DeletedObjectsByHostname -hostname $hostname

    if (-not $objects) {
        Write-Log "No deleted objects found for '$hostname'." "WARN"
        exit
    }

    Write-Log "Displaying deleted objects for selection..."
    $selected = $objects | Select-Object Name, ObjectClass, DistinguishedName, LastKnownParent, Type | 
        Out-GridView -Title "Select objects to restore" -PassThru -OutputMode Multiple

    if (-not $selected) {
        Write-Log "No objects selected. Exiting." "INFO"
        exit
    }

    foreach ($obj in $selected) {
        Write-Log "Restoring: $($obj.Name) [$($obj.ObjectClass)]"
        Restore-ADObject -Identity $obj.DistinguishedName
    }

    Write-Log "Selected objects restored successfully." "SUCCESS"

} catch {
    Write-Log "An error occurred: $_" "ERROR"
}
#endregion
