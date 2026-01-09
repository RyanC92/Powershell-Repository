
# Usage:
#   Save as Get-UniqueDellWarranty.ps1
#   .\Get-UniqueDellWarranty.ps1 -InputCsv .\WarrantyOutput.csv -OutputCsv .\Warranty_ByTag_MaxEnd.csv

param(
    [Parameter(Mandatory=$true)]
    [string]$InputCsv,
    [Parameter(Mandatory=$true)]
    [string]$OutputCsv
)

# Import the CSV
$csv = Import-Csv -Path $InputCsv

if (-not $csv -or $csv.Count -eq 0) {
    throw "No data found in $InputCsv."
}

# Try to auto-detect common column names
$headerNames = $csv[0].psobject.Properties.Name
$serviceTagCol = ($headerNames | Where-Object { $_ -match '^(ServiceTag|Serial|Tag|Service Tag)$' })[0]
$endDateCol    = ($headerNames | Where-Object { $_ -match '^(WarrantyEnd|EndDate|Expiration|Expiry|ExpireDate|End Date)$' })[0]
$modelCol      = ($headerNames | Where-Object { $_ -match '^(Model|DeviceModel|ProductModel|SystemModel|ProductLine Description)$' })[0]
$statusCol     = ($headerNames | Where-Object { $_ -match '^(Status|EntitlementStatus|Entitlement Type)$' })[0]

if (-not $serviceTagCol -or -not $endDateCol) {
    throw "Could not find Service Tag and End Date columns. Found columns: $headerNames"
}

# Optional: If you want to keep only active entitlements, uncomment next line:
# $csv = $csv | Where-Object { $statusCol -and $_.$statusCol -match 'Active' }

# Convert end date to DateTime for correct sorting
$csv | ForEach-Object {
    $_ | Add-Member -NotePropertyName __EndDate -NotePropertyValue ([datetime]) -Force
} | Out-Null

# Group by Service Tag and select the row with the latest end date
$deduped = $csv |
    Where-Object { $_.$serviceTagCol -and $_.__EndDate } |
    Group-Object -Property $serviceTagCol |
    ForEach-Object {
        $latest = $_.Group | Sort-Object -Property __EndDate -Descending | Select-Object -First 1
        [pscustomobject]@{
            ServiceTag  = $latest.$serviceTagCol
            DeviceModel = if ($modelCol) { $latest.$modelCol } else { $null }
            WarrantyEnd = $latest.__EndDate.ToString('yyyy-MM-dd')
        }
    }

# Export result
$deduped | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Done. Saved $($deduped.Count) rows to $OutputCsv"
