#Made specifically for \\pitfile1\data

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

Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
#call to Get-Foldername function to select export directory
$Directory = Get-FolderName
Write-host "Export Directory of $Directory has been selected" -ForegroundColor Green -BackgroundColor Black

#GetNTFSaccess for Pitroot
Write-host "Getting NTFSAccess for \\pitfile1\Data" -ForegroundColor Yellow -BackgroundColor Black
$PitRoot = Get-NTFSAccess \\pitfile1\Data 
$PitRoot | Export-csv "$($Directory)\Report_PitFile1_Data_DirPerms_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -NoTypeInformation
Write-host "NTFS Permissions for $Directory have been exported" -ForegroundColor Green -BackgroundColor Black

Write-host "Getting Childitem list for \\Pitfile1\Data\, Recursion depth of 2, Directory only" -ForegroundColor Yellow -BackgroundColor Black
#Designate the scan path
$SubDir = Get-Childitem -Path \\Pitfile1\Data\ -Directory -Recurse -Depth 2
Write-host "Childitem locations have been collected" -ForegroundColor Green -BackgroundColor Black

#Set value of 0 for progress bar
$i = 0

#Run foreach loop on the contents of Subdir with the Get-ntfsaccess command
ForEach ($subdirscan in $Subdir){

    Write-progress -Activity "Reading NTFS Permissions" -CurrentOperation "$($subdirscan.name)" -Status "Processing $($Subdirscan.name): $i of $($Subdir.count)" -PercentComplete ($i/$($Subdir.name.count)*100);
    #Get-ntfsaccess -Path "$($subdirscan.Fullname)"
    Write-host "Exporting $($Subdirscan.name)" -ForegroundColor Green -BackgroundColor Black
    Get-Ntfsaccess -path "$($subdirscan.Fullname)" | Export-csv "$($Directory)\Report_PitFile1_Data_DirPerms_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -NoTypeInformation -Append

    $i++

}