$SBUsers = Get-ADUser -SearchBase "OU=Users,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org" -filter {streetaddress -like "*3 Paragon*"}

Foreach ($SBUser in $SBUsers){
    Move-ADObject -Identity $SBUser.DistinguishedName -TargetPath "OU=Users,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org"
    "Moving $($SBuser.DisplayName) to OU=Users,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org"
}
"Moved $($SBuser.count) Users"
