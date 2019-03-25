$Array = Read-Host "Enter Distribution Groups, Separated by a comma"
$Member = Read-Host "Enter the user's Display Name"

ForEach ($item in $Array) { Add-DistributionGroupMember -Identity $Item -Member $Member -BypassSecurityGroupManagerCheck } 

Get-DistributionGroupMember -Identity $Member 