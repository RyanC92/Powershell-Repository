$Users = Get-aduser -filter * -SearchBase "" -properties Displayname

$dpOld = '(SOM)'
$dpNew = '(NJ)'

ForEach($User in $Users){

    $dpNJ = $User.Displayname.replace("$($dpold)","$($dpnew)")
    set-aduser -identity $user.samaccountname -Displayname $dpNJ

}