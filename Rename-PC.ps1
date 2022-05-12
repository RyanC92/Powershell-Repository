#Rename Computer based on set prefix (replace the 2 values in Preold and Prenew )

$hn = hostname
$PreOld = 'som'
$PreNew = 'njo'

    $hnNew = $hn.replace("$($PreOld)","$($PreNew)")
    $hnNew.ToUpper()
    Rename-Computer -NewName $hnNew  -Force

Start-sleep -s 3