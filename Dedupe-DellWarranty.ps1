
#Requires -Version 5.1
<#
.SYNOPSIS
    Deduplicate Dell warranty CSV (one row per ServiceTag with latest EndDate),
    prompting the user to select the input and output files via dialog boxes.

.DESCRIPTION
    - Prompts for the input CSV (OpenFileDialog).
    - Prompts for the output CSV path (SaveFileDialog).
    - Parses EndDate, groups by ServiceTag, selects max EndDate.
    - Writes a compact CSV with: ServiceTag, Model, EndDate (YYYY-MM-DD).

.NOTES
    Run on Windows with a desktop session (dialogs). If you need CLI-only usage,
    use the parameterized version I sent earlier.
#>

[CmdletBinding()]
param(
    # Optional: if you pass these, the script skips dialogs.
    [string]$InputCsv,
    [string]$OutputCsv
)

# --- Load Windows Forms assemblies for dialogs ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-OpenFileDialog {
    param(
        [string]$Title = "Select Warranty CSV",
        [string]$Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*",
        [string]$InitialDirectory = [Environment]::GetFolderPath('Desktop')
    )
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Title = $Title
    $ofd.Filter = $Filter
    $ofd.InitialDirectory = $InitialDirectory
    $ofd.Multiselect = $false
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $ofd.FileName }
    return $null
}

function Show-SaveFileDialog {
    param(
        [string]$Title = "Save Deduped Warranty CSV",
        [string]$DefaultFileName = "Warranty_ByTag_MaxEnd.csv",
        [string]$Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*",
        [string]$InitialDirectory = [Environment]::GetFolderPath('Desktop')
    )
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Title = $Title
    $sfd.Filter = $Filter
    $sfd.InitialDirectory = $InitialDirectory
    $sfd.FileName = $DefaultFileName
    $sfd.OverwritePrompt = $true
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $sfd.FileName }
    return $null
}

# --- If not provided, prompt via dialogs ---
if (-not $InputCsv) {
    $InputCsv = Show-OpenFileDialog -Title "Select the raw Dell warranty export CSV"
    if (-not $InputCsv) { Write-Warning "No input file selected. Aborting."; return }
}
if (-not (Test-Path -LiteralPath $InputCsv)) {
    Write-Error "Input file not found: $InputCsv"; return
}

if (-not $OutputCsv) {
    # Suggest an output filename next to the input
    $suggest = Join-Path -Path (Split-Path -Parent $InputCsv) -ChildPath "Warranty_ByTag_MaxEnd.csv"
    $OutputCsv = Show-SaveFileDialog -Title "Choose where to save the deduped CSV" -DefaultFileName (Split-Path -Leaf $suggest)
    if (-not $OutputCsv) { Write-Warning "No output file chosen. Aborting."; return }
}

# --- Import CSV ---
try {
    $csv = Import-Csv -Path $InputCsv
} catch {
    Write-Error "Failed to read input CSV '$InputCsv'. $_"
    return
}

if (-not $csv -or $csv.Count -eq 0) {
    Write-Error "No data found in '$InputCsv'."
    return
}

# --- Validate required columns ---
$headers = $csv[0].PSObject.Properties.Name
$required = @('ServiceTag','Model','EndDate')
$missing  = $required | Where-Object { $headers -notcontains $_ }
if ($missing.Count) {
    Write-Error "Missing required columns: $($missing -join ', '). Found: $($headers -join ', ')"
    return
}

# --- Parse EndDate to DateTime (supports common formats) ---
$knownFormats = @(
    'yyyy-MM-dd','yyyy-MM-ddTHH:mm:ss','yyyy-MM-ddTHH:mm:ssZ',
    'MM/dd/yyyy','M/d/yyyy','MM/dd/yyyy HH:mm','M/d/yyyy H:mm',
    'dd/MM/yyyy','d/M/yyyy','yyyyMMdd'
)

function Try-ParseDate([string]$s){
    if([string]::IsNullOrWhiteSpace($s)){ return $null }
    # direct cast
    try { return [datetime]$s } catch {}
    # exact formats
    foreach($fmt in $knownFormats){
        try { return [datetime]::ParseExact($s,$fmt,$null) } catch {}
    }
    return $null
}

foreach($row in $csv){
    $row | Add-Member -NotePropertyName EndDT -NotePropertyValue (Try-ParseDate $row.EndDate) -Force
}

# --- Keep rows with a parsable EndDate & ServiceTag ---
$clean = $csv | Where-Object { $_.ServiceTag -and $_.EndDT }

if (-not $clean -or $clean.Count -eq 0) {
    Write-Warning "No rows had a parsable EndDate. Check the EndDate formats in '$InputCsv'."
    return
}

# --- Group by ServiceTag; select the row with the latest EndDate ---
$latest =
    $clean |
    Group-Object ServiceTag |
    ForEach-Object {
        $_.Group | Sort-Object EndDT -Descending | Select-Object -First 1
    } |
    Select-Object @{n='ServiceTag';e={$_.ServiceTag}},
                  @{n='Model';e={$_.Model}},
                  @{n='EndDate';e={$_.EndDT.ToString('yyyy-MM-dd')}} |
    Sort-Object ServiceTag

# --- Export ---
try {
    $latest | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
    Write-Host "Deduped $($latest.Count) ServiceTags → '$OutputCsv'" -ForegroundColor Green
} catch {
    Write-Error "Failed to write output CSV '$OutputCsv'. $_"
}
