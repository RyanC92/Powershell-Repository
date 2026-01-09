
 
# Requires Active Directory module to be present
#Requires -Module ActiveDirectory
 
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [string]$OU,
    [string]$CsvPath = "C:\Temp\IntuneDevices.csv"
)
 
# ===== 1. VALIDATION & SETUP =====
 
if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at: $CsvPath"
    return
}
 
Write-Host "Loading Intune devices from CSV: $CsvPath" -ForegroundColor Cyan
$csv = Import-Csv -Path $CsvPath
 
if ($csv.Count -eq 0) {
    Write-Error "No rows found in CSV."
    return
}
 
# CSV Column Headers
# CRITICAL: These must match your CSV exactly.
$cols = @{
    Name   = "Device name"
    User   = "Primary user display name"
    Model  = "Model"
    Serial = "Serial number"
}
 
# SAFETY CHECK: Verify headers exist before doing anything.
$csvHeaders = $csv[0].PSObject.Properties.Name
foreach ($key in $cols.Keys) {
    $expectedCol = $cols[$key]
    if ($csvHeaders -notcontains $expectedCol) {
        Write-Error "CRITICAL ERROR: The CSV is missing the column '$expectedCol'."
        Write-Warning "Check your CSV or update the `$cols variable in the script."
        return 
    }
}
 
# ===== 2. BUILD LOOKUP =====
 
Write-Verbose "Building lookup table..."
$devicesByName = @{}
 
foreach ($row in $csv) {
    $name = $row.($cols.Name)
    if ([string]::IsNullOrWhiteSpace($name)) { continue }
 
    $nameKey = $name.Trim()
 
    if (-not $devicesByName.ContainsKey($nameKey)) {
        $devicesByName[$nameKey] = @()
    }
    $devicesByName[$nameKey] += $row
}
 
Write-Host "Index built. Found $($devicesByName.Keys.Count) unique device names." -ForegroundColor Green
 
# ===== 3. PROCESS AD COMPUTERS =====
 
Write-Host "Querying AD for computers..." -ForegroundColor Cyan
try {
    $adComputers = Get-ADComputer -SearchBase $OU -Filter * -Properties Description, Name -ErrorAction Stop
}
catch {
    Write-Error "Failed to query AD. Check your OU path and permissions."
    return
}
 
Write-Host "Processing $($adComputers.Count) computers..." -ForegroundColor Cyan
 
foreach ($adComp in $adComputers) {
    $compName    = $adComp.Name
    $currentDesc = $adComp.Description
    $newDesc     = $null
 
    if (-not $devicesByName.ContainsKey($compName)) {
        $newDesc = "NOT IN INTUNE"
    }
    else {
        $matches = $devicesByName[$compName]
 
        if ($matches.Count -gt 1) {
            $newDesc = "DUPLICATE NAME IN INTUNE"
        }
        else {
            $row = $matches[0]
            $pUser   = if ([string]::IsNullOrWhiteSpace($row.($cols.User)))   { "N/A" } else { $row.($cols.User) }
            $pModel  = if ([string]::IsNullOrWhiteSpace($row.($cols.Model)))  { "N/A" } else { $row.($cols.Model) }
            $pSerial = if ([string]::IsNullOrWhiteSpace($row.($cols.Serial))) { "N/A" } else { $row.($cols.Serial) }
 
            $newDesc = "PrimaryUser: $pUser | Model: $pModel | Serial: $pSerial"
        }
    }
 
    if ("$currentDesc" -ne "$newDesc") {
        try {
            if ($PSCmdlet.ShouldProcess("$compName", "Update Description")) {
                Set-ADComputer -Identity $adComp.DistinguishedName -Description $newDesc -ErrorAction Stop
                Write-Host " [UPDATED] $compName --> $newDesc" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Failed to update $compName : $($_.Exception.Message)"
        }
    }
}
 
Write-Host "Done." -ForegroundColor Cyan
