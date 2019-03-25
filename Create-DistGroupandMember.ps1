 do {

$DistName = Read-Host "Enter the Distribution List Name"
$Alias = Read-Host "Enter the Alias (One Word: I.E SHGAdmissions)"
$PrimAddress = Read-Host "Enter the Primary SMTP Address (Email Address)"

Write-Host "Creating Distribution List"

New-DistributionGroup -Name "$DistName" -DisplayName "$DistName" -Alias "$Alias" -PrimarySmtpAddress $PrimAddress

Write-Host "Distribution List Has Been Created"

$Outside = Read-Host "Should this Distribution List Accept Senders outside of my Organization? Yes/No"

If ($Outside -eq "Yes") {

Set-DistributionGroup "$DistName" -RequireSenderAuthenticationEnabled $False

}
ElseIf ($Outside -eq "No"){

Set-DistributionGroup "$DistName" -RequireSenderAuthenticationEnabled $True

}

$CSVPath = Write-Host "Please Paste the full path to the CSV file (Including the file itself)"

Import-CSV "$CSVPath" | ForEach { Add-DistributionGroupMember -Identity "$DistName" -Members $_.members}

Get-DistributionGroupMember -Identity "$DistName"

$response = Read-Host "Repeat? (Y/N):"

}

while ($response -eq "y")