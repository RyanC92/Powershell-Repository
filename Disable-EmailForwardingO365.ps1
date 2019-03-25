#Reference Change-BulkPW_Reset.ps1 for more details on a finished script.

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

$Users = Import-CSV $Path
$i = 0
ForEach ($user in $users) {

    Set-Mailbox -Identity $User.UserPrincipalName -ForwardingAddress $null -ForwardingSMTPAddress $Null -DeliverTomailboxandforward $False 
    if ($i < 553){
    $i++
    Write-Host "#$i - "$user.DisplayName" is done"
    }
    
    }