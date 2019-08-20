#Reference Change-BulkPW_Reset.ps1 for more details on a finished script.

Function Get-FileName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.Dereferencelinks = $False
  $OpenFileDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName
}
Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}


Write-Host "Select the Shortcut to Transfer"
$Shortcut = Get-FileName

Write-host "Select the List of Computers to transfer the shortcut to"
$Comps = Get-FileName

$SC = $Shortcut
$PCS = Import-CSV $Comps
$i = 0


ForEach ($PC in $PCS){
  #Increment $i from 0 to get a count
  $i++
  #Show progress of the count
  Write-Progress -Activity "Copying $SC" -Status "Copied: $i of $($PCs.count)"
  
  Write-host "Copying to $($PC.Hostname)"
  xcopy $SC "\\$($PC.Hostname)\C$\Users\Public\Desktop" /y 

}

<# ForEach($PC in $PCs){
  Write-Host "Copying to $($PC.Hostname)"
  xcopy $SC "\\$($PC.Hostname)\C$\ProgramData\Microsoft\Windows\Start Menu\"

} #>
