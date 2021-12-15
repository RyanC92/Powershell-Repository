  
#Directory selection for report Import/export
Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #initialize variable $initialDirectory if you'll always be looking in the same location.
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #Change the extension or uncomment to change what it filters by, if at all.
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}
