#Grant Full Access to All user Mailboxes in Office 365

#Open Dialog box
# Get-Mailbox | Add-mailboxpermission -user Alan@domain.com -AccessRights FullAccess

Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    #$OpenFileDialog.initialDirectoiry = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
}

$CSV = Get-Filename

$CSV | ForEach(Add-MailboxPermission -identity $_.UserPrincipalName -User rcurran@excelsiormedical.com -AccessRights fullaccess -InheritanceType all)