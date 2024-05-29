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
$jsonUrl = "https://github.com/TurnerJVDriverRepo/TCCODrivers/raw/main/Driverlist/DriverList.json"

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
            FileSize       = "$([math]::Round($entry.size / 1MB)) MB"
            DownloadURL    = $entry.download_url
            INFFileName    = $match.INFFileName  # Assuming INFFileName is a property in the JSON
        }
        $combinedEntries += $combinedEntry
    }
}

# Reindex the combined entries
$indexedEntries = $combinedEntries | ForEach-Object {
    [PSCustomObject]@{
        Number         = [array]::IndexOf($combinedEntries, $_) + 1
        Name           = $_.Name
        FileSize       = $_.FileSize
        DownloadURL    = $_.DownloadURL
        INFFileName    = $_.INFFileName
    }
}

# Convert indexedEntries to DataTable for DataGridView
$dataTable = New-Object System.Data.DataTable
$columns = @("Number", "Name", "FileSize", "INFFileName", "DownloadURL")
foreach ($col in $columns) {
    $null = $dataTable.Columns.Add($col)
}

foreach ($entry in $indexedEntries) {
    $row = $dataTable.NewRow()
    $row["Number"] = $entry.Number
    $row["Name"] = $entry.Name
    $row["FileSize"] = $entry.FileSize
    $row["DownloadURL"] = $entry.DownloadURL
    $row["INFFileName"] = $entry.INFFileName
    $dataTable.Rows.Add($row)
}

# Create the first form
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = "Select a GitHub Entry"
$form1.Size = New-Object System.Drawing.Size(800, 600)
$form1.StartPosition = "CenterScreen"

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
$form1.Controls.Add($dataGridView)
$form1.Controls.Add($button)

# Variable to hold the selected entry
$script:selectedEntry = $null

# Add event handler for button click
$button.Add_Click({
    if ($dataGridView.SelectedRows.Count -gt 0) {
        $selectedRow = $dataGridView.SelectedRows[0]
        $script:selectedEntry = @{
            Number = $selectedRow.Cells["Number"].Value
            Name = $selectedRow.Cells["Name"].Value
            FileSize = $selectedRow.Cells["FileSize"].Value
            DownloadURL = $selectedRow.Cells["DownloadURL"].Value
            INFFileName = $selectedRow.Cells["INFFileName"].Value
        }
        [System.Windows.Forms.MessageBox]::Show("You selected: " + $script:selectedEntry.Name)
        $form1.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an entry.")
    }
})

# Show the first form
$form1.Add_Shown({$form1.Activate()})
[void]$form1.ShowDialog()

# Create the second form
$form2 = New-Object System.Windows.Forms.Form
$form2.Text = "Enter Printer Information"
$form2.Size = New-Object System.Drawing.Size(400, 300)
$form2.StartPosition = "CenterScreen"

# Create labels and textboxes for Printer IP and DisplayName
$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Text = "Printer IP:"
$labelIP.Location = New-Object System.Drawing.Point(10, 20)
$form2.Controls.Add($labelIP)

$textBoxIP = New-Object System.Windows.Forms.TextBox
$textBoxIP.Location = New-Object System.Drawing.Point(150, 20)
$textBoxIP.Size = New-Object System.Drawing.Size(200, 20)
$form2.Controls.Add($textBoxIP)

$labelDisplayName = New-Object System.Windows.Forms.Label
$labelDisplayName.Text = "Printer DisplayName:"
$labelDisplayName.Location = New-Object System.Drawing.Point(10, 60)
$form2.Controls.Add($labelDisplayName)

$textBoxDisplayName = New-Object System.Windows.Forms.TextBox
$textBoxDisplayName.Location = New-Object System.Drawing.Point(150, 60)
$textBoxDisplayName.Size = New-Object System.Drawing.Size(200, 20)
$form2.Controls.Add($textBoxDisplayName)

# Create a button to submit the printer information
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Size = New-Object System.Drawing.Size(100, 30)
$submitButton.Location = New-Object System.Drawing.Point(150, 100)
$submitButton.Text = "Submit"
$form2.Controls.Add($submitButton)

# Add event handler for submit button click
$submitButton.Add_Click({
    $printerIP = $textBoxIP.Text
    $printerDisplayName = $textBoxDisplayName.Text

    if ([string]::IsNullOrWhiteSpace($printerIP) -or [string]::IsNullOrWhiteSpace($printerDisplayName)) {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Printer IP: " + $printerIP + "`nPrinter DisplayName: " + $printerDisplayName)
        $form2.Close()
    }
})

# Show the second form
$form2.Add_Shown({$form2.Activate()})
[void]$form2.ShowDialog()

# Optional: Use the selected entry and printer information in further processing
if ($script:selectedEntry -ne $null) {
    Write-Output "Selected Entry Name: $($script:selectedEntry.Name)"
} else {
    Write-Output "No entry was selected."
}
Write-Output "Printer IP: $printerIP"
Write-Output "Printer DisplayName: $printerDisplayName"
