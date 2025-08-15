<#
.SYNOPSIS
    Recover deleted computer and BitLocker recovery objects from AD.

.DESCRIPTION
    This script prompts for a hostname, searches for deleted AD computer and BitLocker recovery objects,
    allows the user to select from a list, and restores the selected items.

.NOTES
    Author: Ryan Curran
    Created: 2025-05-05
    Version: 1.0
    Requirements: Active Directory module, AD Recycle Bin enabled
#>

# Import required modules
Import-Module ActiveDirectory -ErrorAction Stop
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# Create the main window
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AD Object Restore Tool" Height="600" Width="800"
        WindowStartupLocation="CenterScreen">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,10">
            <TextBlock Text="Hostname:" VerticalAlignment="Center" Margin="0,0,10,0"/>
            <TextBox x:Name="txtHostname" Width="200" Margin="0,0,10,0"/>
            <Button x:Name="btnSearch" Content="Search" Width="100" Height="25" Margin="0,0,10,0"/>
            <TextBlock x:Name="txtSearching" Text="" VerticalAlignment="Center" Foreground="Gray"/>
            <Button x:Name="btnCancel" Content="Cancel" Width="80" Height="25" Visibility="Collapsed"/>
        </StackPanel>
        
        <DataGrid x:Name="dgResults" Grid.Row="1" 
                  AutoGenerateColumns="False" 
                  CanUserAddRows="False"
                  SelectionMode="Extended"
                  SelectionUnit="FullRow"
                  IsReadOnly="False">
            <DataGrid.Columns>
                <DataGridCheckBoxColumn Header="Select" 
                                      Binding="{Binding IsSelected, UpdateSourceTrigger=PropertyChanged}"
                                      Width="60"/>
                <DataGridTextColumn Header="Name" 
                                  Binding="{Binding Name}" 
                                  Width="*"
                                  IsReadOnly="True"/>
                <DataGridTextColumn Header="Type" 
                                  Binding="{Binding ObjectClass}" 
                                  Width="100"
                                  IsReadOnly="True"/>
                <DataGridTextColumn Header="Last Known Parent" 
                                  Binding="{Binding LastKnownParent}" 
                                  Width="*"
                                  IsReadOnly="True"/>
            </DataGrid.Columns>
        </DataGrid>
        
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button x:Name="btnRestore" Content="Restore Selected" Width="120" Height="30" Margin="0,0,10,0"/>
            <Button x:Name="btnClose" Content="Close" Width="80" Height="30"/>
        </StackPanel>
    </Grid>
</Window>
"@

# Load the XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$txtHostname = $window.FindName("txtHostname")
$btnSearch = $window.FindName("btnSearch")
$btnRestore = $window.FindName("btnRestore")
$btnClose = $window.FindName("btnClose")
$btnCancel = $window.FindName("btnCancel")
$txtSearching = $window.FindName("txtSearching")
$dgResults = $window.FindName("dgResults")

# Initialize search cancellation
$script:searchCancelled = $false
$script:searchTimer = $null

# Function to update searching text
function Update-SearchingText {
    param (
        [int]$dotCount
    )
    $txtSearching.Text = "Searching" + ("." * $dotCount)
}

# Function to start searching animation
function Start-SearchingAnimation {
    $script:searchCancelled = $false
    $txtSearching.Visibility = "Visible"
    $btnCancel.Visibility = "Visible"
    $btnSearch.IsEnabled = $false
    
    $dotCount = 1
    $script:searchTimer = [System.Windows.Threading.DispatcherTimer]::new()
    $script:searchTimer.Interval = [TimeSpan]::FromMilliseconds(500)
    $script:searchTimer.Add_Tick({
        if ($script:searchCancelled) {
            $script:searchTimer.Stop()
            $txtSearching.Visibility = "Collapsed"
            $btnCancel.Visibility = "Collapsed"
            $btnSearch.IsEnabled = $true
            return
        }
        
        $dotCount = ($dotCount % 3) + 1
        Update-SearchingText -dotCount $dotCount
    })
    $script:searchTimer.Start()
}

# Function to stop searching animation
function Stop-SearchingAnimation {
    if ($script:searchTimer) {
        $script:searchTimer.Stop()
    }
    $txtSearching.Visibility = "Collapsed"
    $btnCancel.Visibility = "Collapsed"
    $btnSearch.IsEnabled = $true
}

# Cancel button click handler
$btnCancel.Add_Click({
    $script:searchCancelled = $true
    Stop-SearchingAnimation
})

# Add cell click handler for the DataGrid
$dgResults.Add_PreviewMouseLeftButtonUp({
    param($sender, $e)
    $cell = [System.Windows.Media.VisualTreeHelper]::HitTest($dgResults, $e.GetPosition($dgResults)).VisualHit
    $checkBox = $null
    while ($cell -and -not $checkBox) {
        if ($cell.GetType().Name -eq "CheckBox") {
            $checkBox = $cell
            break
        }
        $cell = [System.Windows.Media.VisualTreeHelper]::GetParent($cell)
    }
    if ($checkBox) {
        $checkBox.IsChecked = !$checkBox.IsChecked
        $e.Handled = $true
    }
})

# Add Enter key handler for the hostname textbox
$txtHostname.Add_KeyDown({
    param($sender, $e)
    if ($e.Key -eq 'Return') {
        $btnSearch.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
    }
})

# Initialize results array
$script:searchResults = @()

# Function to write to log
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Function to search for deleted objects
function Get-DeletedObjectsByHostname {
    param (
        [string]$hostname
    )
    Write-Log "Searching for deleted objects matching hostname '$hostname'..."
    
    # Create a more flexible search pattern
    $searchPattern = "*$hostname*"
    $filter = @"
    (
        (Name -like '$searchPattern' -or SamAccountName -like '$searchPattern') -and 
        (ObjectClass -eq 'computer')
    ) -or
    (
        (LastKnownParent -like '*$hostname*') -and 
        (ObjectClass -eq 'msFVE-RecoveryInformation')
    )
"@
    
    Write-Log "Using search pattern: $searchPattern"
    $deletedObjects = Get-ADObject -Filter $filter -IncludeDeletedObjects -Properties *
    $deletedObjects
}

# Search button click handler
$btnSearch.Add_Click({
    $hostname = $txtHostname.Text.Trim()
    if (-not $hostname) {
        [System.Windows.MessageBox]::Show("Please enter a hostname to search for.", "Input Required", "OK", "Warning")
        return
    }

    Start-SearchingAnimation

    try {
        $results = Get-DeletedObjectsByHostname -hostname $hostname
        if ($results -is [System.Array]) {
            $script:searchResults = $results
        } elseif ($results) {
            $script:searchResults = @($results)
        } else {
            $script:searchResults = @()
        }
        if ($script:searchCancelled) {
            return
        }
        
        if (-not $script:searchResults) {
            [System.Windows.MessageBox]::Show("No deleted objects found for '$hostname'.", "No Results", "OK", "Information")
            $dgResults.ItemsSource = $null
            return
        }

        # Add IsSelected property to each object
        $script:searchResults = $script:searchResults | ForEach-Object {
            $_ | Add-Member -NotePropertyName "IsSelected" -NotePropertyValue $false -Force -PassThru
        }
        $script:searchResults = @($script:searchResults)
        
        $dgResults.ItemsSource = $script:searchResults
    }
    catch {
        [System.Windows.MessageBox]::Show("Error during search: $_", "Search Error", "OK", "Error")
    }
    finally {
        Stop-SearchingAnimation
    }
})

# Restore button click handler
$btnRestore.Add_Click({
    $selectedItems = $script:searchResults | Where-Object { $_.IsSelected }
    if (-not $selectedItems) {
        [System.Windows.MessageBox]::Show("Please select at least one object to restore.", "Selection Required", "OK", "Warning")
        return
    }

    $result = [System.Windows.MessageBox]::Show(
        "Are you sure you want to restore the selected items?",
        "Confirm Restore",
        "YesNo",
        "Question"
    )

    if ($result -eq "Yes") {
        foreach ($obj in $selectedItems) {
            try {
                Write-Log "Restoring: $($obj.Name) [$($obj.ObjectClass)]"
                Restore-ADObject -Identity $obj.DistinguishedName
            }
            catch {
                Write-Log "Error restoring $($obj.Name): $_" "ERROR"
                [System.Windows.MessageBox]::Show(
                    "Error restoring $($obj.Name):`n$_",
                    "Restore Error",
                    "OK",
                    "Error"
                )
            }
        }
        [System.Windows.MessageBox]::Show("Selected objects restored successfully.", "Success", "OK", "Information")
        
        # Refresh the search results
        $btnSearch.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
    }
})

# Close button click handler
$btnClose.Add_Click({
    $window.Close()
})

# Show the window
$window.ShowDialog() | Out-Null 