Add-Type -AssemblyName PresentationFramework, PresentationCore

# XAML UI
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="LAPS UI" Height="350" Width="500" WindowStartupLocation="CenterScreen">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>

        <TextBlock Grid.Row="0" Grid.Column="0" Text="Computer name:" VerticalAlignment="Center"/>
        <TextBox x:Name="ComputerNameBox" Grid.Row="0" Grid.Column="1" Width="250" Margin="5"/>

        <Button x:Name="SearchButton" Grid.Row="1" Grid.ColumnSpan="2" Content="Search" Width="80" HorizontalAlignment="Left" Margin="0,10,0,5"/>

        <TextBlock Grid.Row="2" Grid.ColumnSpan="2" Text="Output:" Margin="0,5,0,0"/>
        <TextBox x:Name="OutputBox" Grid.Row="3" Grid.ColumnSpan="2" AcceptsReturn="True" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" Height="100"/>

        <Button x:Name="ExitButton" Grid.Row="5" Grid.Column="1" Content="Exit" Width="60" Height="25" HorizontalAlignment="Right" Margin="0,10,0,0"/>
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

# Exit button logic
$ExitButton.Add_Click({ $Window.Close() })

# Run the UI
$Window.ShowDialog() | Out-Null
