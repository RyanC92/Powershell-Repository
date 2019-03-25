Function Get-FileName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.initialDirectory = $initialDirectory
  $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName
}

$Path = Get-FileName

$Path | ForEach-Object { 

    Set-SPUser -Identity "Medline-NT\$_.SamAccountName" -Email "$_.UserPrincipalName" -Web http://Intranet

}        