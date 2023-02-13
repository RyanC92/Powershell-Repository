Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Fix Application" Height="350" Width="525">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Button x:Name="ApplySapFixButton" Content="Apply SAP Fix" HorizontalAlignment="Left" Margin="10,10,0,0" Grid.Row="0"/>
        <Button x:Name="ApplyOfficeMacroFixButton" Content="Apply Office Macro Fix" HorizontalAlignment="Left" Margin="10,10,0,0" Grid.Row="1"/>
        <Button x:Name="ApplyAllFixesButton" Content="Apply All Fixes" HorizontalAlignment="Left" Margin="10,10,0,0" Grid.Row="2"/>
        <TextBox x:Name="OutputLog" IsReadOnly="True" Margin="10,10,10,10" Grid.Row="3"/>
    </Grid>
</Window>
"@

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

$ApplySapFixButton = $Window.FindName("ApplySapFixButton")
$ApplyOfficeMacroFixButton = $Window.FindName("ApplyOfficeMacroFixButton")
$ApplyAllFixesButton = $Window.FindName("ApplyAllFixesButton")
$OutputLog = $Window.FindName("OutputLog")

$ApplySapFixButton.Add_Click({
    $OutputLog.AppendText("SAP Fix applied.`n")
})

$ApplyOfficeMacroFixButton.Add_Click({
    $OutputLog.AppendText("Office Macro Fix applied.`n")
})

$ApplyAllFixesButton.Add_Click({
    $OutputLog.AppendText("All fixes applied.`n")
})

$Window.ShowDialog()
