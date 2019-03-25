Import-module activedirectory

# "OU=Role,OU=Groups,OU=Special,DC=excelsior,DC=local"
# "OU=FileShares,OU=Security,OU=Groups,OU=Special,DC=excelsior,DC=local"
# "OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=excelsior,DC=local"
# 

$result = @()
$ou = "OU=FileShares,OU=Security,OU=Groups,OU=Special,DC=excelsior,DC=local"


Get-ADGroup -Filter * -SearchBase $OU | select -ExpandProperty name | % {
$group= "$_"
$result += Get-ADGroupMember -identity "$_" | select @{n="Group";e={$group}},Name 
}
$result | export-csv 'C:\CSV\Roles-membership_03-10-17.csv' -notypeinformation