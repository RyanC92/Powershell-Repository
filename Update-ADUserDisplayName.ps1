$Users = Get-aduser -filter * -SearchBase "OU=Users,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org" -properties Displayname

$dpOld = '(SOM)'
$dpNew = '(NJ)'

ForEach($User in $Users){

    $dpNJ = $User.Displayname.replace("$($dpold)","$($dpnew)")
    set-aduser -identity $user.samaccountname -Displayname $dpNJ

}