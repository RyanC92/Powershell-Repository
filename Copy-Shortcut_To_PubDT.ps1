#Reference Change-BulkPW_Reset.ps1 for more details on a finished script.

Function Get-FileName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.initialDirectory = $initialDirectory
  $OpenFileDialog.filter = "*"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName
}


Write-Host "Select the Shortcut to Transfer"
$Shortcut = Get-FileName

Write-host "Select the List of Computers to transfer the shortcut to"
$Comps = Get-FileName

$SC = "$Shortcut"
$PCS = Import-CSV "$Comps"


Copy-item $SC "\\$PCS.Hostname\C$\Users\Public\Desktop"