<# 
.SYNOPSIS
    Compare Active Directory users against Intune users with E5 Licenses.

.DESCRIPTION
    This script compares Active Directory users from a specified AD group 
    against a list of E5-licensed users from a user-selected CSV file.

.PARAMETER ADGroup
    Enter the Active Directory group name that contains the users you want to compare.

.PARAMETER Path
    (No longer required as input)  
    The script will prompt you to select a CSV file using a Windows file dialog.

.EXAMPLE
    Example usage:
    PS> .\Intune-E5ADUserCheck.ps1 -ADGroup "TUR.ALL.MDM.USERS"

.NOTES
    Author: Ryan Curran
    Version: 1.2
    Change Log:
        - v1.0: Initial creation
        - v1.1: AD & CSV comparison, regex-based OU extraction, and report generation
        - v1.2: Implemented Windows File Dialog for CSV selection
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
    [Parameter(Mandatory = $false, HelpMessage = "Enter the Active Directory group name.")]
    [ValidateNotNullOrEmpty()]
    [string]$ADGroup
)

# ----------------------
# FILE SELECTION DIALOG
# ----------------------
Add-Type -AssemblyName System.Windows.Forms

function Select-CSVFile {
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $OpenFileDialog.Filter = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $OpenFileDialog.Title = "Select E5 Users CSV File"

    if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $OpenFileDialog.FileName
    } else {
        Write-Host "No file selected. Exiting script." -ForegroundColor Red
        exit
    }
}

# Prompt user to select a file
$Path = Select-CSVFile
Write-Host "Selected file: $Path" -ForegroundColor Cyan

# Prompt user to enter the AD group name if not provided as a parameter
if (-not $ADGroup) {
    $ADGroup = Read-Host "Enter the Active Directory group name"
}

# ----------------------
# MAIN SCRIPT LOGIC
# ----------------------
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

    # Convert AD members to a lookup table for fast matching
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
