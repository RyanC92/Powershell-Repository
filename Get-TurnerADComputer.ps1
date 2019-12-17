#Directory selection for report export
Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}



#Find a computer based on the description or hostname
Write-host "This Script will help find information on a Domain connected computer" -ForegroundColor Yellow
Write-host "=====================================================================================================================" -ForegroundColor Red
Write-host "Enter all or part of the hostname or identifying information that would be in the description of the computer `n(Partial input may return multiple results)" -ForegroundColor Yellow
Write-host "=====================================================================================================================" -ForegroundColor Red
$HNDes = Read-host  "Enter Here"
$HNDes = "*$HNDes*"

#Setup ad query choices for properties
$Title = Write-host "Do You Want All Properties Printed?" -ForegroundColor Yellow -BackgroundColor Black
$Prompt = "Enter your Choice"
$Choices = [System.management.Automation.Host.ChoiceDescription[]] @("&Yes","&No","&Cancel")
$Default = 1
$Choice = $Host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

#Action based on the choice number in switch format
switch($Choice) 
{
    
    0 { $Type = "All_Properties"
        $Report = Get-adcomputer -filter {Description -like $HNDes -or Name -like $HNDes} -properties * | Select * 
        Get-adcomputer -filter {Description -like $HNDes -or Name -like $HNDes} -properties * | Select *
        }
    1 { $Type = "Description_Only"
        $Report = Get-Adcomputer -Filter {Description -like $HNDes -or Name -like $HNDes} -properties description
        Get-Adcomputer -Filter {Description -like $HNDes -or Name -like $HNDes} -properties description
        }
    2 { Write-Host "Cancelled" -ForegroundColor Red }

}

#setup export switch options
$Title = Write-host "Do you want this information Exported?" -ForegroundColor Green
$Prompt = "Enter your Choice"
$Choices = [System.management.Automation.Host.ChoiceDescription[]] @("&Yes","&No")
$Default = 1
$Choice = $Host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

#Export Action based on choice number in switch format

switch($Choice)
{

        0 { Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
            $Directory = Get-FolderName            
            
            $Report | Export-csv "$($Directory)\Report_ADComputer_AllProperties_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation 
            "Report has been exported to $($Directory)\Report_ADComputer_$($Type)_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"

            }

        1 { Write-Host "No Export Option Selected" -ForegroundColor Red 
            }

}