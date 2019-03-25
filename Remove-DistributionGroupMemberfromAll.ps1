$user = $args[0]
if (!$args[0]) {
	
}
$mailbox=get-mailbox $user

$dgs= Get-DistributionGroup
 
foreach($dg in $dgs){
    
    $DGMs = Get-DistributionGroupMember -identity $dg.Identity
    foreach ($dgm in $DGMs){
        if ($dgm.name -eq $mailbox.name){
       
            write-host 'User Found In Group' $dg.identity
              Remove-DistributionGroupMember $dg.Name -Member $user
        }
    }
}