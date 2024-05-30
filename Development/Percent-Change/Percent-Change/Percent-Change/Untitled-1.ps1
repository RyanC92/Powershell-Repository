

$inputXML = @"
    <Window x:Class="Percent_Change.Percent-Change"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:local="clr-namespace:Percent_Change"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Percent Change"
        Width="280.282"
        Height="108.652"
        mc:Ignorable="d">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition />
        </Grid.ColumnDefinitions>
        <TextBlock
            Width="75"
            Height="21"
            Margin="10,10,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            RenderTransformOrigin="-0.306,-0.531"
            Text="Initial Value:"
            TextWrapping="Wrap" />
        <TextBlock
            Width="75"
            Height="21"
            Margin="10,31,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            RenderTransformOrigin="-0.306,-0.531"
            Text="Future Value:"
            TextWrapping="Wrap" />
        <TextBlock
            Width="88"
            Height="21"
            Margin="10,52,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            RenderTransformOrigin="-0.306,-0.531"
            Text="Percent-Change:"
            TextWrapping="Wrap" />
        <TextBox
            Width="81"
            Height="23"
            Margin="103,10,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            Text="Y2"
            TextWrapping="Wrap" />
        <TextBox
            Width="81"
            Height="23"
            Margin="103,29,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            Text="Y1"
            TextWrapping="Wrap" />
        <TextBox
            Width="81"
            Height="23"
            Margin="103,50,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            Text="% Change"
            TextWrapping="Wrap" />
        <Button
            Width="75"
            Margin="189,50,0,0"
            HorizontalAlignment="Left"
            VerticalAlignment="Top"
            Content="Calculate" />
    </Grid>
    </Window>
"@

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

$reader=(New-Object System.Xml.XmlNodeReader $xaml)

try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}

$xaml.SelectNodes("//*[@Name]") | %{"trying item $($_.Name)" | out-null;
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop | out-null }
    catch{throw}
    }

Function Get-FormVariables{
    if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
        write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
}