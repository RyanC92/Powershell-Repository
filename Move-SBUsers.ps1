# add pit nyn alb phi

$OUs = @(
    'OU=Users,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Albany,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Buffalo,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org'
    )

$Target = 'OU=Users,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org'

ForEach($OU in $OUs){
    "Running for $OU"
    $SBUsers = Get-aduser -SearchBase $OU -Filter {streetaddress -like "*3 Paragon*"}
    "Found $($SBusers.count)"
    ForEach($SBUser in $SBUsers){
        Move-ADObject -Identity $SBUser.DistinguishedName -TargetPath $Target
        Write-host "Moving $($SBuser.DisplayName) to $Target" -ForegroundColor Green
    }

    Write-host "Moved $($SBusers.count) Users from $OU" -ForegroundColor Green

}