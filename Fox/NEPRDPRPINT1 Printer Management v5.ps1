
#$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
#add-type -name win -member $t -namespace native
#[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)
$inputXML = @"
<Window x:Class="_1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:_1"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition Width="0*"/>
        </Grid.ColumnDefinitions>
        <ComboBox x:Name="Combobox_building" HorizontalAlignment="Left" Margin="35,83,0,0" VerticalAlignment="Top" Width="85" Height="23" IsEditable="True" IsReadOnly="True" Text="Building"/>
        <RadioButton x:Name="RadioButton_local" Content="Local" HorizontalAlignment="Left" Margin="35,30,0,0" VerticalAlignment="Top" IsChecked="True"/>
        <RadioButton x:Name="RadioButton_remote" Content="Remote" HorizontalAlignment="Left" Margin="35,50,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="Textbox_Hostname" HorizontalAlignment="Left" Height="17" Margin="117,48,0,0" TextWrapping="Wrap" Text="Hostname" VerticalAlignment="Top" Width="120" IsEnabled="False"/>
        <TextBlock HorizontalAlignment="Left" Margin="343,83,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Text="Available Printers:"/>
        <TextBlock HorizontalAlignment="Left" Margin="35,65,0,0" TextWrapping="Wrap" Text="Please select a building:" VerticalAlignment="Top" Width="127"/>
        <Button x:Name="Button_intallprinters" Content="Install Printers" HorizontalAlignment="Left" Margin="662,370,0,0" VerticalAlignment="Top" Width="83"/>
        <Grid HorizontalAlignment="Left" Height="243" Margin="343,104,0,0" VerticalAlignment="Top" Width="402" RenderTransformOrigin="-0.994,-0.397">
            <ListBox x:Name="ckb" HorizontalAlignment="Left" Height="243" VerticalAlignment="Top" Width="392" SelectionMode="Multiple"/>
        </Grid>
    </Grid>
</Window>
"@
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Form=[Windows.Markup.XamlReader]::Load( $reader )
<#
try{
    
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
#>


$xaml.SelectNodes("//*[@Name]") | %{"trying item $($_.Name)";
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

Get-FormVariables

#Disabled for testing
<#$printer = Get-Printer | Where { $_.Location -like "$cob*"}
$printer.Location#>







$WPFRadioButton_remote.Add_Checked({
     $WPFTextbox_Hostname.IsEnabled=$true
     })
$WPFRadioButton_remote.Add_UnChecked({
    $WPFTextbox_Hostname.IsEnabled=$false
    })


"1919",
"1923",
"1930",
"1933",
"Xerox" | ForEach-object {$WPFCombobox_building.AddChild($_)}

Write-Host $wpf

$WPFCombobox_building.Add_DropDownClosed({

	$cob = $WPFCombobox_building.Text
	Write-Host "You Selected: $cob"

	#Disabled for testing
	<#$printer = Get-Printer | Where { $_.Location -like "$cob*"}
	$printer.Location#>
	$global:printers = import-csv  C:\CSV\PrinterExport.csv | Where { $_.Location -like "$cob*"}
	$printers = import-csv  C:\CSV\PrinterExport.csv | Where { $_.Location -like "$cob*"}


	$WPFckb.Items.Clear()

foreach ($printer in $printers) {

  $printer.name = $printer.name -replace '[^a-zA-Z0-9]',''

	$NewCheckbox = New-Object System.Windows.Controls.Checkbox
    $NewCheckbox.Name = "$($printer.name)"
    $NewCheckbox.Content = "$($printer.Sharename)"
    $NewCheckbox.Height = 20

    $WPFckb.AddChild($NewCheckbox)



	}
})




$WPFButton_intallprinters.Add_Click({
	$global:cob = $WPFCombobox_building.Text


$Form.Close()
})


write-host "To show the form, run the following" -ForegroundColor Cyan







function Show-Form{
$Form.ShowDialog() | out-null

}
<#
function installPrinter{

    rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\"

}

function deletePrinter{

    rundll32 printui.dll,PrintUIEntry /in /gd /n "\\NEPPRDPRINT1\"

}#>


Show-Form



	$box = $WPFckb.Items
	$tests = $box.IsChecked

		$te = $global:printers.name


	If($te.Length -match $tests.Length)
{
    For($i=0;$i -lt $te.Length; $i++) 
    {

		if ("$($tests[$i])" -eq $true) {Write-Host "$($te[$i])" "is true"}

    }
}


