$users = Import-CSV C:\CSV\AplicareEmail.CSV  

ForEach ($user in $users) {

$dn = $user.DisplayName

    Get-Aduser -Filter { displayName -like $dn} | select samaccountname | export-csv C:\CSV\AplicareEmailSamAccountName.csv -append -NoTypeInformation


}

$samacc = Import-CSV C:\CSV\AplicareEmailSamAccountName.csv

ForEach ($samaccs in $samacc) {

$san = $samaccs.SamAccountName

    Add-ADGroupMember -Identity evprepenable -Members $_.SamAccountName

} 
