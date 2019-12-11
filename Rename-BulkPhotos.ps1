Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}

$Folder = Get-FolderName
Write-Host "Warning: This will Overwrite any files with the same name/number in the directory you selected" -Foregroundcolor Red
$JobName = Read-host "Enter a Prefix name for the pictures (Ex: NJBU)" 


$i = 0
$Items = Get-Childitem -Path "$Folder"
$Counts = Get-Childitem -path "$Folder" | Measure
$Counts.count

Foreach($Item in $Items){
        $i++
        rename-item -Path $Item.FullName -Newname "$($JobName)_$($i)"
        Write-Host "Renamed $($Item.name) to $($Jobname)_$($i)" -Foregroundcolor Green
    }
