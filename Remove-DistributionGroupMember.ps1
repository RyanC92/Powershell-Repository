$member = Read-Host "Enter a User"
$Group = Read-Host "Enter a Group Title"

Remove-DistributionGroupMember -Identity "$Group" -Member $Member