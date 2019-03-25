#Get All Mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited


#Output File
$OutputFile = "C:\CSV\ActiveSyncUsers.CSV"

#Loop it

ForEach ($Mailbox in $mailboxes) {

    $devices = Get-MobileDeviceStatistics -Mailbox $mailbox.samaccountname

} 

  $Devices      