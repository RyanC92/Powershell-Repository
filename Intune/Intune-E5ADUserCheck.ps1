<# 
.SYNOPSIS
    Compare Active Directory users against Intune users with E5 Licenses.

.DESCRIPTION
    Compare Active Directory users that are in the TUR.ALL.MDM.USERS group and compare them against users who have E5 Licenses.
    Mark the difference in an exported report.

.PARAMETER <ParameterName>
    ADGroup - Enter the active directory group name that contains the users you want to compare.
    Path - Enter the path to the CSV file that contains the users with E5 licenses.

.EXAMPLE
    Example usage:
    PS> .\Intune-E5ADUserCheck.ps1 -ADGroup <AD GroupName> -Path <Path to CSV>

.NOTES
    Author: Ryan Curran
    Date: <2025-02-21>
    Version: 1.0
    Purpose: Build a report detailing the differences between AD users and Intune users with E5 licenses.
    Change Log:
        - v1.0: Initial creation

#>

# ----------------------
# SCRIPT CONFIGURATION
# ----------------------
# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ----------------------
# PARAMETERS
# ----------------------

param (
    [Parameter(Mandatory = $false, HelpMessage = "Enter the Active Directory group name.")]
    [ValidateNotNullOrEmpty()]
    [string]$ADGroup,

    [Parameter(Mandatory = $false, HelpMessage = "Enter the file or folder path.")]
    [ValidateScript({
        if (-Not (Test-Path $_)) {
            Write-Warning "The path '$_' does not exist. Please enter a valid path."
            return $false
        }
        return $true
    })]
    [string]$Path
)

# ----------------------
# INTERACTIVE PROMPTS (IF NO PARAMETERS ARE PROVIDED)
# ----------------------
if (-not $ADGroup) {
    $ADGroup = Read-Host "Enter the Active Directory group name"
}

if (-not $Path) {
    do {
        $Path = Read-Host "Enter the file or folder path"
        if (-Not (Test-Path $Path)) {
            Write-Host "Invalid path. Please enter a valid path." -ForegroundColor Red
        }
    } while (-Not (Test-Path $Path))
}

# ----------------------
# MAIN SCRIPT LOGIC
# ----------------------
#Measure script execution time
Measure-Command {

Write-Host "Processing AD Group: $ADGroup" -ForegroundColor Cyan
Write-Host "Checking Path: $Path" -ForegroundColor Cyan

# Retrieving AD Group Members
try {
    Write-Host "Querying Active Directory for group members..." -ForegroundColor Cyan
    $Members = Get-ADGroupmember -Identity $ADGroup | Get-ADuser -Properties Displayname, UserPrincipalName, DistinguishedName, msDS-ExternalDirectoryObjectId -ErrorAction Stop
    Write-Host "Found $($Members.Count) members in the group '$ADGroup'." -ForegroundColor Green
}
catch {
    Write-Host "Error: Could not retrieve members for group '$ADGroup'. Error: $_" -ForegroundColor Red
}


# Processing a File or Directory
if (Test-Path $Path) {
    Write-Host "Valid path detected: $Path" -ForegroundColor Green
    if (Test-Path $Path -PathType Container) {
        Write-Host "The path is a directory."
    }
    elseif (Test-Path $Path -PathType Leaf) {
        $E5Users = Import-Csv -Path $Path
        Write-Host "Found $($E5Users.Count) users with E5 licenses." -ForegroundColor Green
    }
}

ForEach-Object ($Member in $Members){
    $matchEntry = @()
    $i++

    # Extract the desired OU (e.g., "New Jersey") from the DistinguishedName
    $ouPattern = "(?<=,OU=)([^,]+)" # Regex to match the first OU
    $ouMatches = [regex]::Matches($Member.DistinguishedName, $ouPattern)
    $userOU = if ($ouMatches.Count -ge 2) { $ouMatches[1].Value } else { "Unknown OU" }

    if ($Member.UserPrincipalName -eq $)
    $matchEntry += [PSCustomObject]@{
        DisplayName = $Member
    }
}



Write-Host "Script execution completed successfully." -ForegroundColor Cyan

} # End of Measure-Command