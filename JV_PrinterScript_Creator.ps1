########################
#Created by Ryan Curran#
# 7/24/24              #
# Ver. 3.0.1           #
########################

Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!" -ForegroundColor DarkGreen
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}

#Check Script is running with Elevated Privileges
Check-RunAsAdministrator

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
$jsonUrl = "https://github.com/TurnerJVDriverRepo/TCCODrivers/raw/main/bin/DriverList.json"

# Use Invoke-RestMethod to download the JSON content and parse it into a PowerShell object
try {
    $jsonContent = Invoke-RestMethod -Uri $jsonUrl
    Write-Output "JSON content has been successfully retrieved and parsed."
} catch {
    Write-Output "An error occurred while fetching the JSON content: $($_.Exception.Message)"
}

# Retrieve entries from the GitHub repository
$entries = Get-GitHubContent -OwnerName TurnerJVDriverRepo -RepositoryName TCCODrivers -Path drivers | Select-Object -ExpandProperty Entries

$entries
# Combine JSON data with entries based on matching "FileName" and "Name"
$combinedEntries = @()
foreach ($entry in $entries) {
    $match = $jsonContent | Where-Object { $_.FileName -like $entry.name }
    $match
    if ($match) {
        $combinedEntry = [PSCustomObject]@{
            PrinterModel   = $entry.name -replace '\.zip$', ''
            Name           = $entry.name
            FileSize       = "$([math]::Round($entry.size / 1MB)) MB"
            DownloadURL    = $entry.download_url
            INFFileName    = $match.INFFileName  # Assuming INFFileName is a property in the JSON
            DriverLabel     = $match.DriverLabel
        }
        $combinedEntries += $combinedEntry
    }
}

# Reindex the combined entries
$indexedEntries = $combinedEntries | ForEach-Object {
    [PSCustomObject]@{
        Number         = [array]::IndexOf($combinedEntries, $_) + 1
        PrinterModel   = $_.PrinterModel
        Name           = $_.Name
        FileSize       = $_.FileSize
        DownloadURL    = $_.DownloadURL
        INFFileName    = $_.INFFileName
        DriverLabel     = $_.DriverLabel
    }
}

# Convert indexedEntries to DataTable for DataGridView
$dataTable = New-Object System.Data.DataTable
$columns = @("Number", "Printer Model", "Name", "INF File Name", "Driver Label", "File Size","Download URL")
foreach ($col in $columns) {
    $null = $dataTable.Columns.Add($col)
}

foreach ($entry in $indexedEntries) {
    $row = $dataTable.NewRow()
    $row["Printer Model"] = $entry.PrinterModel
    $row["Number"] = $entry.Number
    $row["Name"] = $entry.Name
    $row["File Size"] = $entry.FileSize
    $row["Download URL"] = $entry.DownloadURL
    $row["INF File Name"] = $entry.INFFileName
    $row["Driver Label"] = $entry.DriverLabel
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
            PrinterModel = $selectedRow.Cells["Printer Model"].Value
            Name = $selectedRow.Cells["Name"].Value
            FileSize = $selectedRow.Cells["File Size"].Value
            DownloadURL = $selectedRow.Cells["Download URL"].Value
            INFFileName = $selectedRow.Cells["INF File Name"].Value
            DriverLabel = $selectedRow.Cells["Driver Label"].Value
        }
        [System.Windows.Forms.MessageBox]::Show("You selected: " + $($script:selectedEntry.name))
        $form1.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an entry.")
    }
})

cls

Write-Output "Select a Printer model from the printer driver list window"

Try{
    # Show the first form
    $form1.Add_Shown({$form1.Activate()})
    [void]$form1.ShowDialog()
}catch [System.SystemException]{
    Write-Warning "Printer List Failed to launch"
}

# Create the second form
$form2 = New-Object System.Windows.Forms.Form
$form2.Text = "Enter Printer Information"
$form2.Size = New-Object System.Drawing.Size(400, 175)
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
$labelDisplayName.Text = "Printer Display Name:"
$labelDisplayName.Location = New-Object System.Drawing.Point(10, 60)
$form2.Controls.Add($labelDisplayName)

$textBoxDisplayName = New-Object System.Windows.Forms.TextBox
$textBoxDisplayName.Location = New-Object System.Drawing.Point(150, 60)
$textBoxDisplayName.Size = New-Object System.Drawing.Size(200, 20)
$form2.Controls.Add($textBoxDisplayName)

# Create a button to submit the printer information
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Size = New-Object System.Drawing.Size(100, 30)
$submitButton.Location = New-Object System.Drawing.Point(150, 90)
$submitButton.Text = "Submit"
$form2.Controls.Add($submitButton)

# Add event handler for submit button click
$submitButton.Add_Click({
    $script:printerIP = $textBoxIP.Text
    $script:printerDisplayName = $textBoxDisplayName.Text
    $script:DriverLabel = $($script:selectedEntry.DriverLabel)

    if ([string]::IsNullOrWhiteSpace($printerIP) -or [string]::IsNullOrWhiteSpace($printerDisplayName)) {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Printer IP: " + $script:printerIP + "`nPrinter DisplayName: " + $script:printerDisplayName + "`nDriver Label: " + $($script:selectedEntry.DriverLabel))
        $form2.Close()
    }
})

Try{
    # Show the second form
    $form2.Add_Shown({$form2.Activate()})
    [void]$form2.ShowDialog()
}catch [System.SystemException]{
    Write-Warning "Printer Settings GUI Failed to launch"
}


# Optional: Use the selected entry and printer information in further processing
if ($selectedEntry -ne $null) {
    Write-Output "Selected Entry Name: $($selectedEntry.Name)"
} else {
    Write-Output "No entry was selected."
}

Write-host "Printer IP: $printerIP
Printer DisplayName: $printerDisplayName
Printer Model: $($selectedEntry.PrinterModel)
Printer Driver Name: $DriverLabel
`nGenerating Printer Script in C:\Temp\
" -ForegroundColor Green

Pause

$scriptcontent = @"

########################
#Created by Ryan Curran#
# 7/24/24              #
# Ver. 3.0.1           #
########################

Add-Type -assembly "system.io.compression.filesystem"
Add-Type -AssemblyName PresentationCore,PresentationFramework

#---------------------Static Values---------------------------
#Dont change these values
`$tcpipPort = "9100"
`$userpath = "`$env:userprofile\Downloads\"
#---------------------End Static Values-----------------------

`$tc = Test-Connection github.com -Count 1 -Quiet
if (`$tc -eq `$True) {
    Write-Output "Connection Test Success"
    Write-Output "Testing URL: Github.com`n"
} else {
    [System.Windows.MessageBox]::Show("Connection test failed, please make sure you are connected to the internet. `nTesting URL: Github.com")
    exit
}

#Window Title
`$host.UI.RawUI.WindowTitle = "Installing Printer $PrinterDisplayName"

Write-Output "Installing $printerDisplayName Printer, Please Wait..."

# Initialize progress
`$progressActivity = "Installing Printer"
`$progressStatus = "Initializing"
`$percentComplete = 0

Write-Progress -Activity `$progressActivity -Status `$progressStatus -PercentComplete `$percentComplete

# Update progress for downloading the driver
`$percentComplete = 25
`$progressStatus = "Downloading the printer driver from the external repo (GitHub)"
Write-Progress -Activity `$progressActivity -Status `$progressStatus -PercentComplete `$percentComplete
Write-Output "`$ProgressStatus"

Try{
    # Download driver from GitHub
    Invoke-WebRequest -Uri $($selectedEntry.DownloadURL) -Outfile "`$env:userprofile\Downloads\$($selectedEntry.Name)"

    #Get contents of the zip file for the folder name
    Write-Output "Opening Zip to read folder name"
    `$zipFile = [IO.Compression.ZipFile]::OpenRead("`${userpath}$($selectedEntry.name)")
    `$normalizePath = @()
    `$normalizePath = `$zipFile.Entries.Fullname -Replace '\\', '/'
    `$driverFolderName = Foreach-object {`$normalizePath -split '/' | Select-Object -First 1} | select-object -Unique
    `$zipFile.Dispose()

    Write-Output "Closing Zip"

    `$driverFolderName

    # Update progress for extracting the driver
    `$percentComplete = 65
    `$progressStatus = "Extracting the Printer Driver"
    Write-Progress -Activity `$progressActivity -Status `$progressStatus -PercentComplete `$percentComplete 
    Write-Output "`$ProgressStatus"

    `$dirtest = Get-ChildItem `$userpath | Select-Object -ExpandProperty Name
    if (`$dirtest -contains "`$driverFoldername") {
        Write-Output "File `$driverFoldername detected in `$userpath, overwriting the driver folder"
        Remove-Item -Path "`$userpath\`$driverFoldername" -Recurse -Force
        Write-Output "Expanding $($selectedEntry.Name) archive"
        Expand-Archive -Path "`$userpath\$($selectedEntry.Name)" -DestinationPath "`$userpath\" -Force
    } else {
        Write-Output "No Driver folder detected in `$userpath, expanding driver archive"
        Expand-Archive -Path "`$userpath\$($selectedEntry.Name)" -DestinationPath "`$userpath\" -Force
    }

    #find the INF file
    Write-output "Searching for $($SelectedEntry.INFFileName) in `$userpath`$driverFoldername"
    `$INFPath = Get-childitem -Path "`$userpath\`$driverFoldername" -Recurse -Filter "$($SelectedEntry.INFFileName)" | select FullName -First 1

    `$INFPath.FullName

    # Update progress for creating the printer port
    `$percentComplete = 75
    `$progressStatus = "Creating the Printer port"
    Write-Progress -Activity `$progressActivity -Status `$progressStatus -PercentComplete `$percentComplete
    Write-Output "`$progressStatus"

    # Create Printer TCPIP Port
    CSCRIPT /nologo `$env:windir\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r "$printerIP" -o raw -n 9100 -h "$printerIP"
    Write-Output "Printer port created with IP $printerIP"

    # Update progress for creating the printer entry
    `$percentComplete = 90
    `$progressStatus = "Creating Printer Entry $printerDisplayName"
    Write-Progress -Activity `$progressActivity -Status `$progressStatus -PercentComplete `$percentComplete
    Write-Output "`$progressStatus"

    # Create Printer Entry
    rundll32 printui.dll,PrintUIEntry /dl /q /n "$printerDisplayName"
    rundll32 printui.dll,PrintUIEntry /if /n "$PrinterDisplayName" /b "$PrinterDisplayName" /f "`$(`$INFPath.FullName)" /r $printerIP /m "$DriverLabel"

    # Update progress to completion
    `$percentComplete = 100
    `$progressStatus = "Installation Complete"
    Write-Progress -Activity `$progressActivity -Status `$progressStatus -PercentComplete `$percentComplete
    Write-Output "`$progressStatus"
    [System.Windows.MessageBox]::Show("Printer $PrinterDisplayName is now Installed")

}catch [System.SystemException]{
    Write-Warning "Something Failed, please screenshot the error and email rcurran@tcco.com"
}

"@

"Testing Dir Path for C:\Temp\Driver\"
$dirtest = test-path "C:\Temp\Driver"

if($dirtest -eq $False){
    "`n Dir path not found, creating C:\Temp\Driver"
    New-Item -Path "C:\Temp\Driver" -ItemType Directory

}else{
    "`n Dir path found, skipping creation"
}

$filetest = test-path "C:\Temp\Driver\Right Click - Run With Powershell.ps1"
$ziptest = test-path "C:\Temp\Driver\$PrinterDisplayName.zip"

if($filetest -eq $True){
    "C:\Temp\Driver\Right Click - Run With Powershell.ps1 found, deleting."
    Remove-Item -Path "C:\Temp\Driver\Right Click - Run With Powershell.ps1"

}else{

}

New-Item -Path "C:\Temp\Driver\" -Name "Right Click - Run with PowerShell.ps1" -ItemType File
Set-Content -Path "C:\Temp\Driver\Right Click - Run with PowerShell.ps1" -Value $scriptcontent
Compress-Archive "C:\Temp\Driver\Right Click - Run With Powershell.ps1" -DestinationPath "C:\Temp\Driver\$PrinterDisplayName" -Force
Get-Childitem -Path C:\Temp\Driver -Filter "*.ps1" | Foreach-Object {Remove-Item -Path $_.FullName -Recurse}

[System.Windows.Forms.MessageBox]::Show("Zip file has been created")

ii "C:\Temp\Driver\"