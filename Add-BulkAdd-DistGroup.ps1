#Bulk Create Distribution Group

$Path = Read-Host "Enter Bulk Distribution List CSV"

Import-CSV -Path $Path | ForEach-Object { New-DistributionGroup -Name $_.Alias  -DisplayName "$_.DisplayName" -Alias "$_.Alias" -PrimarySmtpAddress $_.PrimAddress | Add-DistributionGroupMember -Identity $_.PrimAddress -Member $_.Member | Set-DistributionGroup "$_.DisplayName" -RequireSenderAuthenticationEnabled $False }

Write-Host "Distribution List Has Been Created"

$Outside = Read-Host "Should this Distribution List Accept Senders outside of my Organization? Yes/No"

#If ($Outside -eq "Yes") {

#Set-DistributionGroup "$DisplayName" -RequireSenderAuthenticationEnabled $False

#}
#ElseIf ($Outside -eq "No"){

#Set-DistributionGroup "$DisplayName" -RequireSenderAuthenticationEnabled $True

#}