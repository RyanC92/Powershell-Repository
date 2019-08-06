$UDL = Get-Childitem -Path "\\USNJFS001\H$\"

$i = 0

ForEach ($UDList in $UDL){
    $Perc = $i/$UDL.Count*100
    Write-progress -Activity "Removing Orphaned SID's" -Status "$i Complete of $($UDL.Count)" -PercentComplete $Perc;

    $Perms = Get-NTFSACCESS -PAth "\\USNJFS001\H$\$($UDList.Name)" | Where {$_.Account -like "S-1*"}
    "Processing $($UDList.Name)"
    
    ForEach($Perm in $Perms){

        "Removing $($Perm.Account) for $($UDList.Name)"
        Remove-NTFSAccess -Path "\\USNJFS001\H$\$($UDLIST.Name)" -Account $Perm.Account -AccessRights $Perm.AccessRights
    
    }

$i++

}