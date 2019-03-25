$DisplayName = Read-Host "Enter the Distribution List Name"
$Alias = Read-Host "Enter the Alias (One Word: I.E SHGAdmissions)"
$PrimAddress = Read-Host "Enter the Primary SMTP Address (Email Address)"

Write-Host "Creating Distribution List"

New-DistributionGroup -Name "$DisplayName" -DisplayName "$DisplayName" -Alias "$Alias" -PrimarySmtpAddress $PrimAddress

Write-Host "Distribution List Has Been Created"

$Outside = Read-Host "Should this Distribution List Accept Senders outside of my Organization? Yes/No"

If ($Outside -eq "Yes") {

Set-DistributionGroup "$DistName" -RequireSenderAuthenticationEnabled $False

}
ElseIf ($Outside -eq "No"){

Set-DistributionGroup "$DistName" -RequireSenderAuthenticationEnabled $True

}