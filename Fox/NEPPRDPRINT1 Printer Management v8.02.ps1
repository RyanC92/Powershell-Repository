#Uncomment this to HIDE the powershell window (you will only see the GUI)
<#$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)
#>


#Installs modules needed for progress bar
<#$mod = Test-Path C:\Users\Urban\Documents\WindowsPowerShell\Modules\PoshProgressBar\0.132\PoshProgressBar.psm1

if ($mod -eq $false) {
Install-PackageProvider -Name NuGet -scope CurrentUser -force
Install-Module -Name PoshProgressBar -Scope CurrentUser -force
	}
#>

Try{
    Import-Module -Name PoshProgressBar -Erroraction stop
}Catch{
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
    Install-Module -Name PoshProgressBar -Scope CurrentUser -Force
    Import-Module -Name PoshProgressBar

}
 

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
#>
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
#get-variable WPF*
}

#Get-FormVariables

#Disabled for testing
<#$printer = Get-Printer | Where { $_.Location -like "$cob*"}
$printer.Location#>


#Remote or Local - If the Remote is not selected, disable hostname box (in GUI)
$WPFRadioButton_remote.Add_Checked({
     $WPFTextbox_Hostname.IsEnabled=$true
     })
$WPFRadioButton_remote.Add_UnChecked({
    $WPFTextbox_Hostname.IsEnabled=$false
    })

#List buildings / options
"1919",
"1923",
"1930",
"1933",
"Xerox" | ForEach-object {$WPFCombobox_building.AddChild($_)}

#Write the selection
#Write-Host $wpf

#Will proceed when you select a building 
$WPFCombobox_building.Add_DropDownClosed({

    #$cob is the combo box option that the user selects
    $cob = $WPFCombobox_building.Text
    #write out the choice
	#Write-Host "You Selected: $cob"

    #If cob is equal to Xerox then do this if not, then run the code in else
	if ($cob -eq "Xerox") {
		
		$global:printers = Get-Printer -Computername NEPPRDPRINT1 | Where { $_.Comment -like "*$cob*"} | sort-object Sharename
		$printer = Get-Printer -Computername NEPPRDPRINT1 | Where { $_.Comment -like "*$cob*"} | sort-object Sharename

		#Use this for testing
		<#$global:printers = import-csv  c:\powershell-repository\fox\printerexport.csv | where { $_.comment -like "*$cob*"} | sort-object sharename
		$printers = import-csv  c:\powershell-repository\fox\printerexport.csv | where { $_.comment -like "*$cob*"} | sort-object sharename#>
		

	} else {

		
		$global:printers = Get-Printer -Computername NEPPRDPRINT1 | Where { $_.Location -like "$cob*"} | sort-object Sharename
		$printer = Get-Printer -Computername NEPPRDPRINT1 | Where { $_.Location -like "$cob*"} | sort-object Sharename

		#Use this for testing
		<#$global:printers = import-csv  C:\Powershell-Repository\Fox\PrinterExport.csv | Where { $_.Location -like "$cob*"} | sort-object Sharename
		$printers = import-csv  C:\Powershell-Repository\Fox\PrinterExport.csv | Where { $_.Location -like "$cob*"} | sort-object Sharename#>
    
    }
    
    #If another building is selected, remove the printers in "Available Printers:"
	$WPFckb.Items.Clear()

    #Foreach of printers pulled from the CSV (or get-printer) to run through each line and list the printers
    foreach ($printer in $printers) {
		
		#Make the printer name C# / .NET Friendly by removing the spaces and special characters (needs to be alphanumeric)
        $PrinterRename = $printer.name -replace '[^a-zA-Z0-9]',''

		#Create a new object (for the type of object listed below)
        $NewCheckbox = New-Object System.Windows.Controls.Checkbox
        $NewCheckbox.Name = "$($PrinterRename.name)"
        $NewCheckbox.Content = "$($printer.Sharename)"

		#Creates the checkboxes under "Available printers"
        $WPFckb.AddChild($NewCheckbox)

	}
})


#When you click Install Printers, close the form
$WPFButton_intallprinters.Add_Click({
$Form.Close()
})


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
$ProgressBar = New-ProgressBar -IsIndeterminate $False -Size Medium 

	#Items is the full list that exists in WPFckb 
	#They get filtered to IsChecked equals True, select the name, content and isChecked
	$boxes = $WPFckb.Items | where-object {$_.IsChecked -eq $True} | Select name, Content, IsChecked
	#$tests = $box.IsChecked

	$boxesCount = $boxes | measure
	
	$precentc = 100 / $boxesCount.count
	$pc = 0

	$te = $global:printers.name


		foreach ($box in $boxes) {

			Write-ProgressBar -ProgressBar $Progressbar -Activity "Printer Installer" -Status "Installing" -CurrentOperation "$($box.Content)"

			
			if ($WPFTextbox_Hostname.IsEnabled -eq $True){

			
			PSexec64.exe "\\$($WPFTextbox_hostname.text)" powershell.exe /c "rundll32 printui.dll,PrintUIEntry /q /in /ga /n '\\$($Printers.Computername[1])\$($box.Content)'" 
			

			}else{

            Start-Sleep -s 2

			
			rundll32 printui.dll,PrintUIEntry /q /in /ga /n "\\$($Printers.Computername[1])\$($box.Content)"
			
			}

		$pc = $PC + $precentc
		
		Write-ProgressBar -ProgressBar $Progressbar -Activity "Printer Installer" -Status "Installing" -CurrentOperation "$($box.Content)" -PercentComplete $PC

		}

                    
    Close-ProgressBar $ProgressBar
    Start-Sleep -s 5
    
exit


#Add button To remove, list local printers intalled in Available printer list. Select printers then remove. 
#Get printer for local machine, Pass to window, select then do rundll32 printui and remove (/GD)


