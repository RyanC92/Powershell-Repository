#Deliver to Mailbox and forward turned off

Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    #$OpenFileDialog.initialDirectoiry = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
}

$CSV = Get-Filename

Import-CSV "$CSV" | ForEach-Object(Set-Mailbox -Identity $_.UserPrincipalName -DeliverTomailboxandforward $False)