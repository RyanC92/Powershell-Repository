# Load the required assemblies
Add-Type -AssemblyName System.Windows.Forms

# Create the form and its controls
$form = New-Object System.Windows.Forms.Form
$textBox = New-Object System.Windows.Forms.TextBox
$button2 = New-Object System.Windows.Forms.Button
$button3 = New-Object System.Windows.Forms.Button
$button4 = New-Object System.Windows.Forms.Button
$panel = New-Object System.Windows.Forms.Panel


# Configure the form
$form.Text = "Turner Fixes"
$form.Size = New-Object System.Drawing.Size(935, 375)
$form.StartPosition = "CenterScreen"
$form.AutoScale = $true

# Configure the text box
$textBox.Location = New-Object System.Drawing.Size(10, 50)
$textBox.Size = New-Object System.Drawing.Size(200, 75)

# Configure the buttons
$button2.Location = New-Object System.Drawing.Size(10, 10)
$button2.Size = New-Object System.Drawing.Size(100, 25)
$button2.Text = "Apply SAP Connection Fix"
$button3.Location = New-Object System.Drawing.Size(120, 10)
$button3.Size = New-Object System.Drawing.Size(100, 25)
$button3.Text = "Apply Office Macro Fix"
$button4.Location = New-Object System.Drawing.Size(230,10)
$button4.Size = New-Object System.Drawing.Size(100,25)
$button4.Text = "Apply All Fixes"
$richtextBox.Location = New-Object System.Drawing.Point (10,75)
$richtextBox.Size = New-Object System.Drawing.Size(900,250)
$richtextBox.AutoSize = $True



# Add the controls to the form

$form.Controls.Add($button2)
$form.Controls.Add($button3)
$form.Controls.Add($button4)

# Define the event handlers for the buttons
$button1_Click = {
    # Apply the text from the text box to a variable
    $ethAddress = $textBox.Text
    Start-process -Verb RunAs -WindowStyle Hidden powershell.exe "New-ItemProperty -Path 'HKLM:\SOFTWARE\Video Miner\InstalledProducts\Video Miner Pool' -Name 'EthereumAddress' -Value $ethAddress -Force"
    #System.Windows.MessageBox::Show("Ethereum Address has been set to $ethAddress, Restarting the videoMinerSvc")
    Start-process -Verb RunAs -WindowStyle Hidden powershell.exe "Restart-service -Name videoMinerSvc"

}

$button2_Click = {
    # Perform some action
    Write-Host "Start Service"
    Start-process -Verb RunAs -WindowStyle Hidden powershell.exe "Start-service -Name videoMinerSvc"
}

$button3_Click = {
    # Perform some action
    Write-Host "Stop Service"
    Start-process -Verb RunAs -WindowStyle Hidden powershell.exe "Stop-service -Name videoMinerSvc"
}

$button4_Click = {
    # Perform some action
    Write-Host "Restart Service"
    Start-process -Verb RunAs -WindowStyle Hidden powershell.exe "Restart-service -Name videoMinerSvc"

}

$richTextBox | Add-Member -MemberType ScriptMethod -Name "RunCommand" -Value {
    param($command)
    $exec = [System.Diagnostics.Process]::Start("cmd.exe", "/c $command")
    $exec.WaitForExit()
    $richTextBox.AppendText($exec.StandardOutput.ReadToEnd())
  }

# Assign the event handlers to the buttons
$button1.Add_Click($button1_Click)
$button2.Add_Click($button2_Click)
$button3.Add_Click($button3_Click)
$button4.Add_Click($button4_click)

# Show the form
$form.ShowDialog()
