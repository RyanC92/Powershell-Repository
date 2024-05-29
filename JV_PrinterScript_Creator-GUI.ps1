# Define Module Name
$moduleName = "PowerShellForGitHub"
# Check if the module is installed
if (!(Get-Module -ListAvailable -Name $moduleName)) {
    # If the module is not installed, install it
    Write-Output "$moduleName is not installed. Installing..."
    try {
        Install-Module -Name $moduleName -Force -Confirm:$False -Scope CurrentUser
        Write-Output "$moduleName has been installed successfully."
    } catch {
        Write-Output "An error occurred while installing ${moduleName}: $($_.Exception.Message)"
    }
} else {
    Write-Output "$moduleName is already installed."
}

# Add required assemblies
Add-Type -AssemblyName PresentationCore, PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the URL for the raw JSON file
$jsonUrl = "https://raw.githubusercontent.com/TurnerJVDriverRepo/TCCODrivers/main/Driverlist/Driverlist.json"

# Use Invoke-RestMethod to download the JSON content and parse it into a PowerShell object
try {
    $jsonContent = Invoke-RestMethod -Uri $jsonUrl
    Write-Output "JSON content has been successfully retrieved and parsed."
} catch {
    Write-Output "An error occurred while fetching the JSON content: $($_.Exception.Message)"
}

# Retrieve entries from the GitHub repository
$entries = Get-GitHubContent -OwnerName TurnerJVDriverRepo -RepositoryName TCCODrivers | Select-Object -ExpandProperty Entries

# Combine JSON data with entries based on matching "FileName" and "Name"
$combinedEntries = @()
foreach ($entry in $entries) {
    $match = $jsonContent | Where-Object { $_.FileName -eq $entry.name }
    if ($match) {
        $combinedEntry = [PSCustomObject]@{
            Name           = $entry.name
            Path           = $entry.Path
            FileSize       = "$([math]::Round($entry.size / 1MB)) MB"
            DownloadURL    = $entry.download_url
            INFFileName = $match.INFFileName  # Assuming INFFileName is a property in the JSON
        }
        $combinedEntries += $combinedEntry
    }
}

# Reindex the combined entries
$indexedEntries = $combinedEntries | ForEach-Object {
    [PSCustomObject]@{
        Number         = [array]::IndexOf($combinedEntries, $_) + 1
        Name           = $_.Name
        Path           = $_.Path
        FileSize       = $_.FileSize
        DownloadURL    = $_.DownloadURL
        INFFileName = $_.INFFileName
    }
}

# Convert indexedEntries to DataTable for DataGridView
$dataTable = New-Object System.Data.DataTable
$columns = @("Number", "Name", "Path", "FileSize", "DownloadURL", "INFFileName")
foreach ($col in $columns) {
    $null = $dataTable.Columns.Add($col)
}

foreach ($entry in $indexedEntries) {
    $row = $dataTable.NewRow()
    $row["Number"] = $entry.Number
    $row["Name"] = $entry.Name
    $row["Path"] = $entry.Path
    $row["FileSize"] = $entry.FileSize
    $row["DownloadURL"] = $entry.DownloadURL
    $row["INFFileName"] = $entry.INFFileName
    $dataTable.Rows.Add($row)
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select a GitHub Entry"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"

# Create a DataGridView
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Size = New-Object System.Drawing.Size(780, 500)
$dataGridView.Location = New-Object System.Drawing.Point(10, 10)
$dataGridView.DataSource = $dataTable
$dataGridView.SelectionMode = "FullRowSelect"
$dataGridView.MultiSelect = $false
$dataGridView.ReadOnly = $true

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Location = New-Object System.Drawing.Point(350, 520)
$button.Text = "Select"

# Add controls to the form
$form.Controls.Add($dataGridView)
$form.Controls.Add($button)

# Variable to hold the selected entry
$selectedEntry = $null

# Add event handler for button click
$button.Add_Click({
    if ($dataGridView.SelectedRows.Count -gt 0) {
        $selectedRow = $dataGridView.SelectedRows[0]
        $selectedEntry = @{
            Number = $selectedRow.Cells["Number"].Value
            Name = $selectedRow.Cells["Name"].Value
            FileSize = $selectedRow.Cells["FileSize"].Value
            DownloadURL = $selectedRow.Cells["DownloadURL"].Value
            INFFileName = $selectedRow.Cells["INFFileName"].Value
        }
        [System.Windows.Forms.MessageBox]::Show("You selected: " + $selectedEntry.Name)
        $form.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an entry.")
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()

# Optional: Use the selected entry in further processing
Write-Output "Selected entry: $selectedEntry"
