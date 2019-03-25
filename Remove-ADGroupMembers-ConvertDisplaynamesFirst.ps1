$users = Import-CSV C:\CSV\MDB1xxusers.csv

ForEach ($user in $users) {

$dn = $user.DisplayName

    Get-Aduser -Filter { displayName -like $dn} | select samaccountname | export-csv C:\CSV\MDB1Converts.csv -append -NoTypeInformation


}
<#
$samacc = Import-CSV C:\CSV\MDB1Converts.csv

ForEach ($samaccs in $samacc) {

$san = $samaccs.SamAccountName

    Remove-ADGroupMember -Identity evprepenable -Members $_.SamAccountName

} 
#>