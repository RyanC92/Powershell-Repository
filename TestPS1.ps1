Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.initialDirectory = $initialDirectory
  $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFileDialog.ShowDialog() #| Out-Null
  $OpenFileDialog.FileName
}

$CSVFiles = Get-Childitem C:\Powershell -Filter *.csv | out-gridview -Outputmode Multiple

Foreach ($File in $CSVFiles) {

    $Userdata = import-csv $File
    
}