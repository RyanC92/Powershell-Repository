$First = Read-Host "Enter their First Name"
$Last = Read-Host "Enter their last name"
$DisplayName = $First + " " + $Last
$Email = Read-Host "Enter Email Address"
$Title = Read-Host "Enter Title"
$Office = Read-Host "Enter Office"
$PhoneNumber = Read-Host "Enter Phone number"
$StreetAddress = Read-Host "Enter Street Address"
$City = Read-Host "Enter City"
$State = Read-Host "Enter State"
$Postal = Read-Host "Enter Postal Code"
$Password = Read-Host "Enter Password" 

#Creation of the user
New-Msoluser -UserPrincipalName $Email -FirstName $First -LastName $Last -DisplayName $DisplayName `
-Title $Title -Office $Office -PhoneNumber $PhoneNumber -StreetAddress $StreetAddress -City $City `
-State $State -UsageLocation US -PostalCode $Postal -Password $Password -ForceChangePassword $False

Write-host = "Breakdown of Licenses" 

#Get The Account SKUS
Get-MsolAccountSku | Select AccountSkuID,ActiveUnits,ConsumedUnits


#Add User licenses

$Option = Read-Host "1 For E1 and Azure RMS, 2 for E3 and Azure RMS"



if($Option -eq "1"){

Set-Msoluserlicense -UserPrincipalName "$Email" -AddLicenses "NewLeafFlorida:STANDARDPACK","NewLeafFlorida:RIGHTSMANAGEMENT"
Write-Host "E1 and RMS License has been Assigned"
Get-MsolAccountSku | Select AccountSkuID,ActiveUnits,ConsumedUnits

}
elseif($Option -eq "2"){

Set-Msoluserlicense -UserPrincipalName "$Email" -AddLicenses "NewLeafFlorida:ENTERPRISEPACK","NewLeafFlorida:RIGHTSMANAGEMENT"
Write-Host "E3 License has been Assigned"
Get-MsolAccountSku | Select AccountSkuID,ActiveUnits,ConsumedUnits

}#Error
elseif($Option -ne "1" -or "2"){

Write-Host "No Licenses have been Assigned"
}