#Rename Computer based on set prefix (replace the 2 values in )

$Domain = tcco.org
$hn = hostname
#$cred = get-credential
$PreOld = ''
$PreNew = ''

    $hnNew = $hn.replace("$($PreOld)","$($PreNew)")
    Rename-Computer -NewName $hnNew  -Restart