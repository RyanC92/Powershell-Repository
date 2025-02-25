<# 
.SYNOPSIS
    Compare Active Directory users against Intune users with E5 Licenses.

.DESCRIPTION
    Compare Active Directory users that are in the TUR.ALL.MDM.USERS group and compare them against users who have E5 Licenses.
    Mark the difference in an exported report.

.PARAMETER ADGroup
    Enter the Active Directory group name that contains the users you want to compare.

.PARAMETER Path
    Enter the path to the CSV file that contains the users with E5 licenses.

.EXAMPLE
    Example usage:
    PS> .\Intune-E5ADUserCheck.ps1 -ADGroup "TUR.ALL.MDM.USERS" -Path "C:\temp\E5Users.csv"

.NOTES
    Author: Ryan Curran
    Date: <2025-02-21>
    Version: 1.1
    Purpose: Build a report detailing the differences between AD users and Intune users with E5 licenses.
    Change Log:
        - v1.0: Initial creation
        - v1.1: Implemented AD & CSV comparison, regex-based OU extraction, and report generation

#>

# ----------------------
# SCRIPT CONFIGURATION
# ----------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ----------------------
# PARAMETERS
# ----------------------
param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the Active Directory group name.")]
    [ValidateNotNullOrEmpty()]
    [string]$ADGroup,

    [Parameter(Mandatory = $true, HelpMessage = "Enter the file path to the CSV containing E5 users.")]
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
# MAIN SCRIPT LOGIC
# ----------------------

# Measure script execution time
Measure-Command {

    Write-Host "Processing AD Group: $ADGroup" -ForegroundColor Cyan
    Write-Host "Checking Path: $Path" -ForegroundColor Cyan

    # Retrieving AD Group Members
    try {
        Write-Host "Querying Active Directory for group members..." -ForegroundColor Cyan
        $ADMembers = Get-ADGroupMember -Identity $ADGroup | Get-ADUser -Properties DisplayName, UserPrincipalName, DistinguishedName -ErrorAction Stop
        Write-Host "Found $($ADMembers.Count) members in the group '$ADGroup'." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: Could not retrieve members for group '$ADGroup'. Error: $_" -ForegroundColor Red
        exit
    }

    # Import CSV containing E5 users
    try {
        $E5Users = Import-Csv -Path $Path
        Write-Host "Found $($E5Users.Count) users with E5 licenses." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: Could not import CSV from '$Path'. Error: $_" -ForegroundColor Red
        exit
    }

    # Convert AD members to a lookup table for faster matching
    $ADUserLookup = @{}
    foreach ($Member in $ADMembers) {
        # Extract OU from Distinguished Name
        $ouPattern = "(?<=,OU=)([^,]+)" # Regex to match the first OU
        $ouMatches = [regex]::Matches($Member.DistinguishedName, $ouPattern)
        $UserOU = if ($ouMatches.Count -ge 2) { $ouMatches[1].Value } else { "Unknown OU" }

        $ADUserLookup[$Member.UserPrincipalName] = @{
            "DisplayName"     = $Member.DisplayName
            "UserPrincipalName" = $Member.UserPrincipalName
            "DistinguishedName" = $Member.DistinguishedName
            "UserOU"          = $UserOU
            "ExistsInAD"      = $True
        }
    }

    # Prepare results
    $Results = @()

    # Compare AD users with CSV users
    foreach ($E5User in $E5Users) {
        $UPN = $E5User.UserPrincipalName
        if ($ADUserLookup.ContainsKey($UPN)) {
            # Match found in AD
            $Results += [PSCustomObject]@{
                "Display Name"     = $ADUserLookup[$UPN]["DisplayName"]
                "UserPrincipalName" = $UPN
                "Distinguished Name" = $ADUserLookup[$UPN]["DistinguishedName"]
                "OU"               = $ADUserLookup[$UPN]["UserOU"]
                "AD"               = $True
                "E5"               = $True
                "Cross Match"      = $True
            }
        }
        else {
            # User exists in CSV but not in AD
            $Results += [PSCustomObject]@{
                "Display Name"     = "Not Found in AD"
                "UserPrincipalName" = $UPN
                "Distinguished Name" = "N/A"
                "OU"               = "N/A"
                "AD"               = $False
                "E5"               = $True
                "Cross Match"      = $False
            }
        }
    }

    # Define the CSV report file path with timestamp
    $Timestamp = Get-Date -Format "MM-dd-yyyy-HH.mm"
    $ReportFile = "C:\temp\reports\AD-Intune-Comparison-$Timestamp.csv"

    # Export the results to CSV
    $Results | Export-Csv -Path $ReportFile -NoTypeInformation -Encoding UTF8

    Write-Host "Report generated: $ReportFile" -ForegroundColor Green

} # End of Measure-Command

Write-Host "Script execution completed successfully." -ForegroundColor Cyan
