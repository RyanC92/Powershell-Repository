<# 
.SYNOPSIS
    Compare Active Directory users against Intune users with E5 Licenses.

.DESCRIPTION
    This script compares Active Directory users from a specified AD group 
    against a list of E5-licensed users from a user-selected CSV file.

.PARAMETER ADGroup
    Enter the Active Directory group name that contains the users you want to compare.

.EXAMPLE
    Example usage:
    PS> .\Intune-E5ADUserCheck.ps1 -ADGroup "TUR.ALL.MDM.USERS"

.NOTES
    Author: Ryan Curran
    Version: 1.4
    Change Log:
        - v1.0: Initial creation
        - v1.1: AD & CSV comparison, regex-based OU extraction, and report generation
        - v1.2: Implemented Windows File Dialog for CSV selection
        - v1.3: Detects both "UserPrincipalName" and "User Principal Name" in CSV
        - v1.4: Optimized AD group query using Get-ADGroup -Properties Member
#>

# ----------------------
# PARAMETERS
# ----------------------
param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the Active Directory group name.")]
    [ValidateNotNullOrEmpty()]
    [string]$ADGroup
)

# Ensure script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as an administrator. Exiting..." -ForegroundColor Red
    exit
}

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

# ----------------------
# MAIN SCRIPT LOGIC
# ----------------------
Measure-Command {

    # Validate that ADGroup parameter is properly set
    if (-not $ADGroup) {
        Write-Host "Error: ADGroup parameter is missing. Exiting..." -ForegroundColor Red
        exit
    }

    Write-Host "Processing AD Group: $ADGroup" -ForegroundColor Cyan
    Write-Host "Checking Path: $Path" -ForegroundColor Cyan

    # Retrieving AD Group Members using optimized method
    try {
        Write-Host "Querying Active Directory for group members (Optimized Query)..." -ForegroundColor Cyan
        $ADGroupObject = Get-ADGroup -Identity $ADGroup -Properties Members

        if ($ADGroupObject.Members.Count -eq 0) {
            Write-Host "No members found in the group '$ADGroup'." -ForegroundColor Yellow
            exit
        }

        # Retrieve only user accounts from the group
        # Extract only user members from the group
        $UserDNs = $ADGroupObject.Members | Where-Object { $_ -like "CN=*" }

        # Retrieve AD users in batches to avoid multiple queries
        $ADMembers = @()
        foreach ($UserDN in $UserDNs) {
            $User = Get-ADUser -Identity $UserDN -Properties DisplayName, UserPrincipalName, DistinguishedName -ErrorAction SilentlyContinue
            if ($User) {
                $ADMembers += $User
            }
        }

        Write-Host "Found $($ADMembers.Count) user members in the group '$ADGroup'." -ForegroundColor Green
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

    # Detect correct column name in CSV
    $CSVHeaders = $E5Users | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    if ("UserPrincipalName" -in $CSVHeaders) {
        $UPNColumn = "UserPrincipalName"
    } elseif ("User Principal Name" -in $CSVHeaders) {
        $UPNColumn = "User Principal Name"
    } else {
        Write-Host "Error: The CSV file does not contain 'UserPrincipalName' or 'User Principal Name'. Exiting..." -ForegroundColor Red
        exit
    }

    if ("DisplayName" -in $CSVHeaders) {
        $DNColumn = "DisplayName"
    } elseif ("Display Name" -in $CSVHeaders) {
        $DNColumn = "Display Name"
    } else {
        Write-Host "Error: The CSV file does not contain 'DisplayName' or 'Display Name'. Exiting..." -ForegroundColor Red
        exit
    }

    Write-Host "Using column '$UPNColumn' for UserPrincipalName comparison." -ForegroundColor Yellow

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
        $UPN = $E5User.$UPNColumn  # Dynamically reference detected column
        if ($ADUserLookup.ContainsKey($UPN)) {
            # Match found in AD
            $Results += [PSCustomObject]@{
                "Display Name"     = $ADUserLookup[$UPN]["DisplayName"]
                "UserPrincipalName" = $UPN
                "Distinguished Name" = $ADUserLookup[$UPN]["DistinguishedName"]
                "OU"               = $ADUserLookup[$UPN]["UserOU"]
                "ADGroup"          = $True
                "E5 Licensed"      = $True
                "Cross Match"      = $True
            }
        }
        else {
            # User exists in CSV but not in AD
            $Results += [PSCustomObject]@{
                "Display Name"     = $E5User.$DNColumn  # Dynamically reference detected column
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
