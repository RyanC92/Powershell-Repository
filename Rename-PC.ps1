#Rename Computer based on set prefix (replace the 2 values in Preold and Prenew )

$hn = hostname
$PreOld = 'mah'
$PreNew = 'TSI'

    $hnNew = $hn.replace("$($PreOld)","$($PreNew)")
    Rename-Computer -NewName $hnNew  -Restart