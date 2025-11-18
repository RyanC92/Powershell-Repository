Add-Type -AssemblyName PresentationFramework, PresentationCore

# XAML UI
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="LAPS UI"
        Height="300" Width="450" MinHeight="280" MinWidth="400"
        ResizeMode="CanResize" WindowStartupLocation="CenterScreen">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>  <!-- Computer Name -->
            <RowDefinition Height="Auto"/>  <!-- Search Button -->
            <RowDefinition Height="Auto"/>  <!-- Output Label -->
            <RowDefinition Height="Auto"/>  <!-- Output Box -->
            <RowDefinition Height="Auto"/>  <!-- Expiration Row -->
            <RowDefinition Height="*"/>     <!-- Spacer -->
            <RowDefinition Height="Auto"/>  <!-- Bottom Button Row -->
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>

        <!-- Computer name input -->
        <TextBlock Grid.Row="0" Grid.Column="0" Text="Computer name:" VerticalAlignment="Center"/>
        <TextBox x:Name="ComputerNameBox"
                 Grid.Row="0" Grid.Column="1"
                 Width="250" Margin="5"/>

        <!-- Search button -->
        <Button x:Name="SearchButton"
                Grid.Row="1" Grid.ColumnSpan="2"
                Content="Search"
                Width="80"
                HorizontalAlignment="Left"
                Margin="0,10,0,5"
                IsDefault="True"/>

        <!-- Output label -->
        <TextBlock Grid.Row="2" Grid.ColumnSpan="2"
                   Text="Output:"
                   Margin="0,5,0,0"/>

        <!-- Output box -->
        <TextBox x:Name="OutputBox"
                 Grid.Row="3" Grid.ColumnSpan="2"
                 AcceptsReturn="True"
                 IsReadOnly="True"
                 VerticalScrollBarVisibility="Auto"
                 TextWrapping="Wrap"
                 Height="80"/>

        <!-- Expiration row with date picker and Apply -->
        <TextBlock Grid.Row="4" Grid.Column="0"
                   Text="Set New Expiration:"
                   VerticalAlignment="Center"/>
        <StackPanel Grid.Row="4" Grid.Column="1"
                    Orientation="Horizontal"
                    Margin="5,0,0,0">
            <DatePicker x:Name="NewExpirationPicker" Width="160"/>
            <Button x:Name="ApplyButton"
                    Content="Apply"
                    Width="60"
                    Margin="5,0,0,0"/>
        </StackPanel>

        <!-- Bottom row: About (left) + Exit (right) -->
        <Button x:Name="AboutButton"
                Grid.Row="6" Grid.Column="0"
                Content="About"
                ToolTip="About"
                Width="50" Height="25"
                HorizontalAlignment="Left"
                VerticalAlignment="Center"
                Margin="0,10,0,0"/>

        <Button x:Name="ExitButton"
                Grid.Row="6" Grid.Column="1"
                Content="Exit"
                Width="60"
                HorizontalAlignment="Right"
                Margin="0,10,0,0"/>
    </Grid>
</Window>
"@

# Load XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($XAML))
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Get WPF elements
$ComputerNameBox = $Window.FindName("ComputerNameBox")
$SearchButton    = $Window.FindName("SearchButton")
$OutputBox       = $Window.FindName("OutputBox")
$ExitButton      = $Window.FindName("ExitButton")
$NewExpirationPicker = $Window.FindName("NewExpirationPicker")
$ApplyButton         = $Window.FindName("ApplyButton")
$AboutButton     = $Window.FindName("AboutButton")

# Trigger search if Enter is pressed in the textbox
$ComputerNameBox.Add_KeyDown({
    param($sender, $e)
    if ($e.Key -eq 'Enter') {
        $SearchButton.RaiseEvent(
            [System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)
        )
    }
})

# Search button logic
$SearchButton.Add_Click({
    $ComputerName = $ComputerNameBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($ComputerName)) {
        [System.Windows.MessageBox]::Show("Please enter a computer name.", "Validation Error", "OK", "Warning")
        return
    }

    try {
        $result = Get-LapsADPassword -Identity $ComputerName -ErrorAction Stop
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($result.Password)
        $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

        $formatted = @"
Computer Name: $ComputerName
Username: .\Turneradmin
Password: $PlainPassword
Expiration: $($result.ExpirationTimestamp)
"@
        $OutputBox.Text = $formatted
    } catch {
        [System.Windows.MessageBox]::Show("Error retrieving password for '$ComputerName'`n`n$_", "LAPS Error", "OK", "Error")
        $OutputBox.Text = ""
    }
})

# Add event handler for Apply button (robust schema detection)
$ApplyButton.Add_Click({
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue | Out-Null
    Import-Module LAPS -ErrorAction SilentlyContinue | Out-Null  # If Windows LAPS is present

    $ComputerName = $ComputerNameBox.Text.Trim()
    $sel = $NewExpirationPicker.SelectedDate  # $null or [datetime]

    if ([string]::IsNullOrWhiteSpace($ComputerName)) {
        [System.Windows.MessageBox]::Show("Please enter a computer name before applying expiration.", "Validation Error", "OK", "Warning")
        return
    }
    if ($null -eq $sel) {
        [System.Windows.MessageBox]::Show("Please select a new expiration date.", "Validation Error", "OK", "Warning")
        return
    }

    # Use end-of-day LOCAL time to avoid 'already past' after UTC conversion
    $pickedLocal   = [datetime]$sel
    $localDateTime = $pickedLocal.Date.AddHours(23).AddMinutes(59)

    if ($localDateTime.Kind -eq [System.DateTimeKind]::Unspecified) {
        $localDateTime = [datetime]::SpecifyKind($localDateTime, [System.DateTimeKind]::Local)
    }
    if ($localDateTime -lt (Get-Date)) {
        [System.Windows.MessageBox]::Show("The selected expiration is in the past. Please pick a future date.", "Validation Error", "OK", "Warning")
        return
    }

    $utcWhen    = $localDateTime.ToUniversalTime()
    $shownLocal = [System.TimeZoneInfo]::ConvertTimeFromUtc($utcWhen, [System.TimeZoneInfo]::Local)

    try {
        # Pull ALL properties, then test which names exist (no schema errors)
        $comp  = Get-ADComputer -Identity $ComputerName -Properties * -ErrorAction Stop
        $names = $comp.PSObject.Properties.Name

        $hasWinSchema   = ($names -contains 'msLAPS-PasswordExpirationTime') -or ($names -contains 'msLAPS-EncryptedPassword')
        $hasLegacySchema= ($names -contains 'ms-Mcs-AdmPwdExpirationTime') -or ($names -contains 'ms-Mcs-AdmPwd')
        $hasWinCmd      = [bool](Get-Command Set-LapsADPasswordExpirationTime -ErrorAction SilentlyContinue)

        if ($hasWinSchema -and $hasWinCmd) {
            # Windows LAPS path
            Set-LapsADPasswordExpirationTime -Identity $ComputerName -WhenEffective $utcWhen -ErrorAction Stop
            [System.Windows.MessageBox]::Show("New expiration applied (Windows LAPS).`nEffective: $shownLocal (local time)", "Success", "OK", "Information")
        }
        elseif ($hasLegacySchema) {
            # Legacy LAPS path (write Integer8/FILETIME)
            $fileTime = $utcWhen.ToFileTimeUtc()
            Set-ADComputer -Identity $ComputerName -Replace @{ 'ms-Mcs-AdmPwdExpirationTime' = $fileTime } -ErrorAction Stop
            [System.Windows.MessageBox]::Show("New expiration applied (Legacy LAPS).`nEffective: $shownLocal (local time)", "Success", "OK", "Information")
        }
        else {
            # Fallback: try Windows LAPS first (if cmdlet present), else legacy write; surface errors if both fail
            $did = $false
            if ($hasWinCmd) {
                try {
                    Set-LapsADPasswordExpirationTime -Identity $ComputerName -WhenEffective $utcWhen -ErrorAction Stop
                    [System.Windows.MessageBox]::Show("New expiration applied (Windows LAPS).`nEffective: $shownLocal (local time)", "Success", "OK", "Information")
                    $did = $true
                } catch {}
            }
            if (-not $did) {
                try {
                    $fileTime = $utcWhen.ToFileTimeUtc()
                    Set-ADComputer -Identity $ComputerName -Replace @{ 'ms-Mcs-AdmPwdExpirationTime' = $fileTime } -ErrorAction Stop
                    [System.Windows.MessageBox]::Show("New expiration applied (Legacy LAPS).`nEffective: $shownLocal (local time)", "Success", "OK", "Information")
                    $did = $true
                } catch {}
            }
            if (-not $did) {
                throw "Neither Windows LAPS nor Legacy LAPS attribute could be written. Verify schema/policies and permissions."
            }
        }
    } catch {
        [System.Windows.MessageBox]::Show("Failed to set new expiration.`n`n$_", "Error", "OK", "Error")
    }
})



$AboutButton.Add_Click({
    [System.Windows.MessageBox]::Show(
        "Converted for Windows 11 24H2 and Later`nBy Ryan Curran - 2025",
        "About LAPS UI",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    )
})

# Exit button logic
$ExitButton.Add_Click({ $Window.Close() })

# Run the UI
$Window.ShowDialog() | Out-Null
