Add-Type -AssemblyName System.Windows.Forms

# Function to create GUI
function Create-MigrationGUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Device-to-Device Migration"
    $form.Size = New-Object System.Drawing.Size(450, 200)
    $form.StartPosition = "CenterScreen"

    # Label and Textbox for Destination IP
    $lblDestination = New-Object System.Windows.Forms.Label
    $lblDestination.Text = "Destination Device IP:"
    $lblDestination.Location = New-Object System.Drawing.Point(10, 20)
    $form.Controls.Add($lblDestination)

    $txtDestination = New-Object System.Windows.Forms.TextBox
    $txtDestination.Location = New-Object System.Drawing.Point(170, 20)
    $txtDestination.Width = 200
    $form.Controls.Add($txtDestination)

    # Start Migration Button
    $btnStart = New-Object System.Windows.Forms.Button
    $btnStart.Text = "Start Migration"
    $btnStart.Location = New-Object System.Drawing.Point(170, 60)
    $btnStart.Add_Click({
        $destinationIP = $txtDestination.Text

        if (-not $destinationIP) {
            [System.Windows.Forms.MessageBox]::Show("Please enter the Destination IP.")
            return
        }

        Start-Migration -DestinationIP $destinationIP
    })
    $form.Controls.Add($btnStart)

    $form.ShowDialog()
}

# Function to perform the migration
function Start-Migration {
    param (
        [string]$DestinationIP
    )

    try {
        # Dynamically get the current username
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]

        # Paths to migrate
        $chromeFavorites = "C:\Users\$currentUser\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
        $quickAccessLinks = "C:\Users\$currentUser\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"
        $taskbarPins = "C:\Users\$currentUser\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

        # Destination paths
        $destChromeFavorites = "\\$DestinationIP\C$\Users\$currentUser\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
        $destQuickAccessLinks = "\\$DestinationIP\C$\Users\$currentUser\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"
        $destTaskbarPins = "\\$DestinationIP\C$\Users\$currentUser\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

        # Ensure the directories exist before copying
        if (Test-Path $chromeFavorites) {
            Copy-Item -Path $chromeFavorites -Destination $destChromeFavorites -Force
        } else {
            Write-Host "Chrome Favorites not found."
        }

        if (Test-Path $quickAccessLinks) {
            Copy-Item -Path $quickAccessLinks -Destination $destQuickAccessLinks -Recurse -Force
        } else {
            Write-Host "Quick Access Links not found."
        }

        if (Test-Path $taskbarPins) {
            Copy-Item -Path $taskbarPins -Destination $destTaskbarPins -Recurse -Force
        } else {
            Write-Host "Taskbar Pins not found."
        }

        [System.Windows.Forms.MessageBox]::Show("Migration completed successfully!")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error during migration: $_")
    }
}

# Launch the GUI
Create-MigrationGUI
