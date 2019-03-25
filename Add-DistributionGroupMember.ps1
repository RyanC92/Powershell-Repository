$member = Read-Host "Enter a User"

do {

$DistGroup = Read-Host "Enter Distribution Group Keyword"
Get-DistributionGroup -Anr "$DistGroup" | Format-Table Name,PrimarySMTPAddress
$Group = Read-Host "Enter Distribution Groups"

Add-DistributionGroupMember -Identity "$Group" -Member "$Member" -BypassSecurityGroupManagerCheck

$response = Read-Host "Repeat? (Y/N):"
}
while ($response -eq "y")
