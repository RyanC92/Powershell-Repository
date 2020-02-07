cls
#This script requires NTFSSecurity

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

$ScanPath = Read-host "Enter the directory of the location that you want to scan (Ex: \\SOMFILE2\...)"
Write-host "You entered: $ScanPath" -ForegroundColor Green -BackgroundColor Black
$Depth =  Read-host "How many levels deep would you like to scan? (Ex: 1, 2 ... \\Somefile2\Accounting or \\Somefile2\Accounting\Bills...)"
Write-host "You entered a Depth of: $Depth levels" -ForegroundColor Green -BackgroundColor Black

""

$Title = ""
$Info = Write-host "Would you like to scan directories, files or both? (Please note, scanning for both will drastically increase your scantime)" -Foregroundcolor Yellow -Backgroundcolor Black
  
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Directories", "&2. Files", "&3. Both (Directories & Files)", "&4. Quit")
[int]$defaultchoice = 0
$opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
switch($opt)
  {
  0 { Write-Host "Directories" -ForegroundColor Green
      $Scantype = "d"
    }
  1 { Write-Host "Files" -ForegroundColor Green
      $Scantype = "a"
    }
  2 { Write-Host "Both" -ForegroundColor Green
      $Scantype = "a,d"
    }
  3 { Write-Host "Quit" -ForegroundColor Green}
}


Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
#call to Get-Foldername function to select export directory
$Directory = Get-FolderName
Write-host "Export Directory of $Directory has been selected" -ForegroundColor Green -BackgroundColor Black

#Check for the file, if it exists, delete it (This is to Overwrite)
$Filename = "$($Directory)\Report_Data_DirPerms_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv"
if (Test-path $Filename){
  Remove-Item $Filename
}

Write-host "Getting Childitem list for: $ScanPath
  Recursion Depth: $Depth
  Scan Type: $ScanType
  This may take a few minutes" -ForegroundColor Yellow -BackgroundColor Black

#Designate the scan path
$ChildItemScan = Get-Childitem -Path "$ScanPath" -Attributes $Scantype -Recurse -Depth $Depth

Write-host "Childitem locations have been collected" -ForegroundColor Green -BackgroundColor Black

#Set value of 0 for progress bar
$i = 0

#Run foreach loop on the contents of Subdir with the Get-ntfsaccess command
ForEach ($subdirscan in $ChildItemScan){

    Write-progress -Activity "Reading NTFS Permissions" -CurrentOperation "$($subdirscan.name)" -Status "Processing $($Subdirscan.name): $i of $($ChildItemScan.count)" -PercentComplete ($i/$($ChildItemScan.name.count)*100);
    #Get-ntfsaccess -Path "$($subdirscan.Fullname)"
    Write-host "Exporting $($Subdirscan.name)" -ForegroundColor Green -BackgroundColor Black
    Get-Ntfsaccess -path "$($subdirscan.Fullname)" | Export-csv "$($Directory)\Report_Data_DirPerms_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -NoTypeInformation -Append

    $i++

}