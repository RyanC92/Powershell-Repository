$identity = get-mailbox -Identity $args[0]
$groups = Get-DistributionGroup
foreach( $group in $groups)
{
     if ((Get-DistributionGroupMember $group.identity | select -Expand distinguishedname) -contains $identity.distinguishedname){$group.name}
}