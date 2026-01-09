<#
.SYNOPSIS
    Updates Active Directory computer descriptions with Dell warranty information from Intune device data.

.DESCRIPTION
    This script:
    1. Imports device data from Intune CSV export
    2. Queries Dell warranty information using Dell Command Integration Suite
    3. Matches warranty data with Intune device information
    4. Updates AD computer object descriptions with user, model, serial, and warranty end date
    5. Logs all changes to a CSV file

.PARAMETER OU
    MANDATORY. The Distinguished Name of the OU containing computers to update.
    Example: "OU=Workstations,DC=contoso,DC=com"

.PARAMETER Input
    OPTIONAL. Path to the Intune devices CSV file.
    If not provided, a file dialog will open for selection.

.PARAMETER Log
    OPTIONAL. Path and filename for the change log CSV.
    If not provided, a file dialog will open, or defaults to:
    C:\temp\LaptopWarrantyChangeLog-<Date>-<Time>.csv

.PARAMETER WhatIf
    OPTIONAL. Shows what changes would be made without actually making them.

.EXAMPLE
    .\Update-ADComputersWithDellWarranty.ps1 -OU "OU=Laptops,DC=domain,DC=com"

.EXAMPLE
    .\Update-ADComputersWithDellWarranty.ps1 -OU "OU=Laptops,DC=domain,DC=com" -Input "C:\Data\Intune.csv" -WhatIf

.NOTES
    Requirements:
    - Active Directory PowerShell Module
    - Dell Command | Integration Suite for System Center (v6.6.1 or higher)
    - Permissions to query and modify AD computer objects
    - Intune device export CSV with required columns
#>

#Requires -Module ActiveDirectory

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter the Distinguished Name of the OU to process")]
    [ValidateNotNullOrEmpty()]
    [string]$OU,
    
    [Parameter(Mandatory = $false)]
    [string]$Input,
    
    [Parameter(Mandatory = $false)]
    [switch]$Log
)

# ========================================
# FUNCTION DEFINITIONS
# ========================================

function Show-FileDialog {
    <#
    .SYNOPSIS
        Displays a file selection dialog box
    #>
    param(
        [string]$Title = "Select a file",
        [string]$Filter = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*",
        [switch]$Save
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    
    if ($Save) {
        $dialog = New-Object System.Windows.Forms.SaveFileDialog
    } else {
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
    }
    
    $dialog.Title = $Title
    $dialog.Filter = $Filter
    $dialog.InitialDirectory = "C:\Temp"
    
    if ($dialog.ShowDialog() -eq 'OK') {
        return $dialog.FileName
    }
    return $null
}

function Test-DellCommandSuite {
    <#
    .SYNOPSIS
        Checks if Dell Command Integration Suite is installed
    #>
    
    Write-Host "`n[PREREQUISITE CHECK] Verifying Dell Command Integration Suite..." -ForegroundColor Cyan
    
    # Check registry for installed software
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $dellCommandInstalled = $false
    foreach ($path in $registryPaths) {
        $installed = Get-ItemProperty $path -ErrorAction SilentlyContinue | 
                     Where-Object { $_.DisplayName -like "*Dell Command*Integration Suite*System Center*" }
        if ($installed) {
            $dellCommandInstalled = $true
            Write-Host "  ✓ Found: $($installed.DisplayName) (Version: $($installed.DisplayVersion))" -ForegroundColor Green
            break
        }
    }
    
    if (-not $dellCommandInstalled) {
        Write-Error @"
REQUIRED SOFTWARE NOT FOUND: Dell Command | Integration Suite for System Center

This tool is required to query Dell warranty information.

Download from:
https://dl.dell.com/FOLDER12964322M/2/Dell-Command-Integration-Suite-for-System-Center_5FT6F_WIN64_6.6.1_A00_01.EXE

After installation, please re-run this script.
"@
        return $false
    }
    
    # Verify the CLI executable exists
    $cliPath = "C:\Program Files (x86)\Dell\CommandIntegrationSuite\DellWarranty-CLI.exe"
    if (-not (Test-Path $cliPath)) {
        Write-Error "Dell Command Integration Suite is installed, but CLI tool not found at: $cliPath"
        return $false
    }
    
    Write-Host "  ✓ Dell Warranty CLI found at: $cliPath" -ForegroundColor Green
    return $true
}

function Get-LatestWarrantyEndDate {
    <#
    .SYNOPSIS
        Processes Dell warranty output and returns latest end date per service tag
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$WarrantyCsvPath
    )
    
    Write-Verbose "Processing warranty data to find latest end dates..."
    
    $warrantyData = Import-Csv -Path $WarrantyCsvPath
    $latestWarranties = @{}
    
    foreach ($row in $warrantyData) {
        $serviceTag = $row.ServiceTag
        $endDateStr = $row.EndDate
        
        if ([string]::IsNullOrWhiteSpace($serviceTag) -or [string]::IsNullOrWhiteSpace($endDateStr)) {
            continue
        }
        
        try {
            # Parse the end date
            $endDate = [DateTime]::Parse($endDateStr)
            
            # Keep the latest date for each service tag
            if (-not $latestWarranties.ContainsKey($serviceTag) -or $endDate -gt $latestWarranties[$serviceTag]) {
                $latestWarranties[$serviceTag] = $endDate
            }
        }
        catch {
            Write-Warning "Could not parse date '$endDateStr' for service tag '$serviceTag'"
        }
    }
    
    Write-Host "  ✓ Processed $($latestWarranties.Keys.Count) unique service tags with warranty data" -ForegroundColor Green
    return $latestWarranties
}

# ========================================
# MAIN SCRIPT EXECUTION
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Dell Warranty AD Computer Update Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ===== STEP 1: VALIDATE PREREQUISITES =====

# Check for Dell Command Integration Suite
if (-not (Test-DellCommandSuite)) {
    return
}

# Check Active Directory access
Write-Host "`n[PREREQUISITE CHECK] Verifying Active Directory access..." -ForegroundColor Cyan
try {
    $null = Get-ADDomain -ErrorAction Stop
    Write-Host "  ✓ Active Directory module loaded and accessible" -ForegroundColor Green
}
catch {
    Write-Error "Cannot access Active Directory. Ensure you have appropriate permissions and the AD module is available."
    return
}

# Validate OU exists
Write-Host "`n[PREREQUISITE CHECK] Validating OU path..." -ForegroundColor Cyan
try {
    $null = Get-ADOrganizationalUnit -Identity $OU -ErrorAction Stop
    Write-Host "  ✓ OU validated: $OU" -ForegroundColor Green
}
catch {
    Write-Error "Cannot access OU: $OU. Please verify the Distinguished Name is correct."
    return
}

# ===== STEP 2: GET INPUT CSV FILE =====

Write-Host "`n[INPUT] Locating Intune device CSV file..." -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($Input)) {
    Write-Host "  No input file specified. Opening file dialog..." -ForegroundColor Yellow
    $Input = Show-FileDialog -Title "Select Intune Devices CSV File" -Filter "CSV Files (*.csv)|*.csv"
    
    if ([string]::IsNullOrWhiteSpace($Input)) {
        Write-Error "No input file selected. Script cannot continue."
        return
    }
}

if (-not (Test-Path $Input)) {
    Write-Error "Input file not found: $Input"
    return
}

Write-Host "  ✓ Input file: $Input" -ForegroundColor Green

# ===== STEP 3: IMPORT AND VALIDATE CSV COLUMNS =====

Write-Host "`n[DATA IMPORT] Loading Intune device data..." -ForegroundColor Cyan

$intuneDevices = Import-Csv -Path $Input

if ($intuneDevices.Count -eq 0) {
    Write-Error "No data rows found in CSV file."
    return
}

Write-Host "  ✓ Loaded $($intuneDevices.Count) device records" -ForegroundColor Green

# Define required columns (case-insensitive check)
$requiredColumns = @{
    DeviceName = "Device name"
    SerialNumber = "Serial number"
    Model = "Model"
    PrimaryUserUPN = "Primary user UPN"
}

Write-Host "`n[VALIDATION] Checking for required CSV columns..." -ForegroundColor Cyan
$csvHeaders = $intuneDevices[0].PSObject.Properties.Name
$missingColumns = @()

foreach ($key in $requiredColumns.Keys) {
    $expectedColumn = $requiredColumns[$key]
    $found = $csvHeaders | Where-Object { $_ -eq $expectedColumn }
    
    if (-not $found) {
        $missingColumns += $expectedColumn
        Write-Warning "  ✗ Missing column: '$expectedColumn'"
    } else {
        Write-Host "  ✓ Found column: '$expectedColumn'" -ForegroundColor Green
    }
}

if ($missingColumns.Count -gt 0) {
    Write-Error @"
CRITICAL ERROR: CSV is missing required columns.

Missing: $($missingColumns -join ', ')

Please ensure your Intune export includes these columns.
"@
    return
}

# ===== STEP 4: CREATE TEMPORARY CSV FOR DELL WARRANTY LOOKUP =====

Write-Host "`n[WARRANTY LOOKUP] Preparing Dell warranty query..." -ForegroundColor Cyan

# Create temp directory if it doesn't exist
$tempDir = "C:\Temp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Create temporary input CSV for Dell CLI with just Service Tags
$tempInputCsv = Join-Path $tempDir "DellWarrantyInput_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$tempOutputCsv = Join-Path $tempDir "DellWarrantyOutput_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

Write-Host "  Creating temporary service tag list: $tempInputCsv" -ForegroundColor Gray

# Extract unique serial numbers and create Dell input CSV
$serviceTagData = $intuneDevices | 
    Where-Object { -not [string]::IsNullOrWhiteSpace($_.$($requiredColumns.SerialNumber)) } |
    Select-Object @{Name='Service Tag'; Expression={$_.$($requiredColumns.SerialNumber).Trim()}} |
    Sort-Object 'Service Tag' -Unique

$serviceTagData | Export-Csv -Path $tempInputCsv -NoTypeInformation

Write-Host "  ✓ Prepared $($serviceTagData.Count) unique service tags for warranty lookup" -ForegroundColor Green

# ===== STEP 5: QUERY DELL WARRANTY INFORMATION =====

Write-Host "`n[WARRANTY LOOKUP] Querying Dell warranty database..." -ForegroundColor Cyan
Write-Host "  This may take several minutes depending on the number of devices..." -ForegroundColor Yellow

$dellCliPath = "C:\Program Files (x86)\Dell\CommandIntegrationSuite\DellWarranty-CLI.exe"
$dellCliArgs = "/I=`"$tempInputCsv`" /E=`"$tempOutputCsv`""

try {
    $processInfo = Start-Process -FilePath $dellCliPath -ArgumentList $dellCliArgs -Wait -PassThru -NoNewWindow
    
    if ($processInfo.ExitCode -ne 0) {
        Write-Warning "Dell Warranty CLI exited with code: $($processInfo.ExitCode)"
    }
    
    if (-not (Test-Path $tempOutputCsv)) {
        Write-Error "Dell Warranty CLI did not produce output file: $tempOutputCsv"
        return
    }
    
    Write-Host "  ✓ Dell warranty data retrieved successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to execute Dell Warranty CLI: $($_.Exception.Message)"
    return
}

# ===== STEP 6: PROCESS WARRANTY DATA (GET LATEST END DATE PER TAG) =====

Write-Host "`n[DATA PROCESSING] Analyzing warranty end dates..." -ForegroundColor Cyan

$latestWarranties = Get-LatestWarrantyEndDate -WarrantyCsvPath $tempOutputCsv

# ===== STEP 7: BUILD COMBINED DATASET =====

Write-Host "`n[DATA PROCESSING] Building combined device and warranty dataset..." -ForegroundColor Cyan

$combinedData = @()

foreach ($device in $intuneDevices) {
    $deviceName = $device.$($requiredColumns.DeviceName)
    $serialNumber = $device.$($requiredColumns.SerialNumber)
    $model = $device.$($requiredColumns.Model)
    $primaryUserUPN = $device.$($requiredColumns.PrimaryUserUPN)
    
    # Skip if device name is empty
    if ([string]::IsNullOrWhiteSpace($deviceName)) {
        continue
    }
    
    # Extract username from UPN (remove @domain.com)
    $username = if ([string]::IsNullOrWhiteSpace($primaryUserUPN)) {
        "N/A"
    } else {
        $primaryUserUPN.Split('@')[0]
    }
    
    # Look up warranty end date
    $warrantyEndDate = if ($latestWarranties.ContainsKey($serialNumber)) {
        $latestWarranties[$serialNumber].ToString("MM/dd/yyyy")
    } else {
        "Unknown"
    }
    
    # Query AD for user's first and last name
    $firstName = "Unknown"
    $lastName = "User"
    
    if ($username -ne "N/A") {
        try {
            $adUser = Get-ADUser -Identity $username -Properties GivenName, Surname -ErrorAction Stop
            $firstName = if ([string]::IsNullOrWhiteSpace($adUser.GivenName)) { "Unknown" } else { $adUser.GivenName }
            $lastName = if ([string]::IsNullOrWhiteSpace($adUser.Surname)) { "User" } else { $adUser.Surname }
        }
        catch {
            Write-Verbose "Could not find AD user for username: $username"
        }
    }
    
    # Create combined record
    $combinedData += [PSCustomObject]@{
        DeviceName = $deviceName.Trim()
        SerialNumber = $serialNumber
        Model = $model
        PrimaryUserUPN = $primaryUserUPN
        Username = $username
        FirstName = $firstName
        LastName = $lastName
        WarrantyEndDate = $warrantyEndDate
    }
}

Write-Host "  ✓ Combined dataset created with $($combinedData.Count) devices" -ForegroundColor Green

# Export combined data for logging purposes
$updatedADListPath = Join-Path $tempDir "UpdatedADList.csv"
$combinedData | Export-Csv -Path $updatedADListPath -NoTypeInformation
Write-Host "  ✓ Combined data exported to: $updatedADListPath" -ForegroundColor Green

# ===== STEP 8: SETUP CHANGE LOG =====

Write-Host "`n[LOGGING] Setting up change log..." -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($Log)) {
    $defaultLogName = "LaptopWarrantyChangeLog-$(Get-Date -Format 'yyyy-MM-dd')-$(Get-Date -Format 'HH-mm-ss').csv"
    $defaultLogPath = Join-Path $tempDir $defaultLogName
    
    Write-Host "  No log file specified. Opening save dialog..." -ForegroundColor Yellow
    Write-Host "  Default: $defaultLogPath" -ForegroundColor Gray
    
    $Log = Show-FileDialog -Title "Save Change Log As" -Filter "CSV Files (*.csv)|*.csv" -Save
    
    if ([string]::IsNullOrWhiteSpace($Log)) {
        $Log = $defaultLogPath
        Write-Host "  Using default log location" -ForegroundColor Yellow
    }
}

Write-Host "  ✓ Change log will be saved to: $Log" -ForegroundColor Green

# Initialize change log array
$changeLog = @()

# ===== STEP 9: UPDATE AD COMPUTER DESCRIPTIONS =====
Write-Host "`n[AD BACKUP] Querying AD for computer objects in OU and backing up to C:\Temp\ADBackup.csv..." -ForegroundColor Cyan

Get-Adcomputer -SearchBase $OU -Filter * -Properties * | 
    Select-Object Name, Description, DistinguishedName | 
    Export-Csv -Path "C:\Temp\ADBackup.csv" -NoTypeInformation

Write-Host "`n[AD UPDATE] Processing Active Directory computer objects..." -ForegroundColor Cyan

# Query all computers in the specified OU
try {
    $adComputers = Get-ADComputer -SearchBase $OU -Filter * -Properties Description, Name -ErrorAction Stop
    Write-Host "  ✓ Found $($adComputers.Count) computers in OU" -ForegroundColor Green
}
catch {
    Write-Error "Failed to query AD computers in OU: $OU"
    return
}

# Create lookup dictionary for quick access
$deviceLookup = @{}
foreach ($device in $combinedData) {
    $deviceLookup[$device.DeviceName] = $device
}

$updatedCount = 0
$skippedCount = 0
$notInIntuneCount = 0

foreach ($adComp in $adComputers) {
    $compName = $adComp.Name
    $currentDesc = $adComp.Description
    
    # Check if device exists in our Intune data
    if (-not $deviceLookup.ContainsKey($compName)) {
        Write-Verbose "Computer '$compName' not found in Intune data"
        $notInIntuneCount++
        
        # Log this for tracking
        $changeLog += [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerName = $compName
            Action = "Skipped"
            Reason = "Not found in Intune data"
            OldDescription = $currentDesc
            NewDescription = ""
        }
        continue
    }
    
    # Get device data
    $deviceData = $deviceLookup[$compName]
    
    # Build new description
    # Format: FirstName LastName - Model - ServiceTag - Warranty End Date
    $newDesc = "$($deviceData.FirstName) $($deviceData.LastName) - $($deviceData.Model) - $($deviceData.SerialNumber) - $($deviceData.WarrantyEndDate)"
    
    # Check if update is needed
    if ($currentDesc -eq $newDesc) {
        Write-Verbose "Computer '$compName' description is already up to date"
        $skippedCount++
        continue
    }
    
    # Perform the update (respects -WhatIf)
    try {
        if ($PSCmdlet.ShouldProcess("$compName", "Update Description to: $newDesc")) {
            Set-ADComputer -Identity $adComp.DistinguishedName -Description $newDesc -ErrorAction Stop
            Write-Host "  [UPDATED] $compName" -ForegroundColor Green
            Write-Host "    New: $newDesc" -ForegroundColor Gray
            $updatedCount++
            
            # Log the change
            $changeLog += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                ComputerName = $compName
                Action = "Updated"
                Reason = "Description updated with warranty info"
                OldDescription = $currentDesc
                NewDescription = $newDesc
            }
        }
        else {
            # WhatIf was used
            Write-Host "  [WHATIF] Would update $compName" -ForegroundColor Yellow
            Write-Host "    New: $newDesc" -ForegroundColor Gray
            
            $changeLog += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                ComputerName = $compName
                Action = "WhatIf"
                Reason = "Would update description"
                OldDescription = $currentDesc
                NewDescription = $newDesc
            }
        }
    }
    catch {
        Write-Warning "Failed to update '$compName': $($_.Exception.Message)"
        
        $changeLog += [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerName = $compName
            Action = "Failed"
            Reason = $_.Exception.Message
            OldDescription = $currentDesc
            NewDescription = $newDesc
        }
    }
}

# ===== STEP 10: EXPORT CHANGE LOG =====

Write-Host "`n[LOGGING] Saving change log..." -ForegroundColor Cyan

try {
    $changeLog | Export-Csv -Path $Log -NoTypeInformation
    Write-Host "  ✓ Change log saved to: $Log" -ForegroundColor Green
}
catch {
    Write-Error "Failed to save change log: $($_.Exception.Message)"
}

# ===== STEP 11: CLEANUP TEMPORARY FILES =====

Write-Host "`n[CLEANUP] Removing temporary files..." -ForegroundColor Cyan

try {
    Remove-Item $tempInputCsv -Force -ErrorAction SilentlyContinue
    Remove-Item $tempOutputCsv -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ Temporary files cleaned up" -ForegroundColor Green
}
catch {
    Write-Warning "Could not remove temporary files: $($_.Exception.Message)"
}

# ===== STEP 12: SUMMARY =====

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total computers in OU:     $($adComputers.Count)" -ForegroundColor White
Write-Host "Computers updated:         $updatedCount" -ForegroundColor Green
Write-Host "Already up to date:        $skippedCount" -ForegroundColor Gray
Write-Host "Not in Intune:             $notInIntuneCount" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

if ($WhatIfPreference) {
    Write-Host "NOTE: This was a WhatIf run. No actual changes were made to AD." -ForegroundColor Yellow
}

Write-Host "Script completed successfully!`n" -ForegroundColor Green