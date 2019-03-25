

$Option = Read-Host "1 For Exchange Archive License, 2 to remove the license"



if($Option -eq "1"){

$Path = Read-Host "Enter bulk license CSV"

$CSV = Import-CSV -Path "$Path" 

Write-Host "Path is $Path"

$CSV | ForEach-Object { Set-Msoluserlicense -UserPrincipalName "$_.Email" -AddLicenses "ExcelsiorMedical:EXCHANGEARCHIVE" }
Write-Host "Exchange Archive License has been assigned"
Get-MsolAccountSku | Select AccountSkuID,ActiveUnits,ConsumedUnits

}
elseif($Option -eq "2"){

Set-MsolUserLicense -Userprincipalname "$_.Email" -RemoveLicenses "ExcelsiorMedical:EXCHANGEARCHIVE"

}
elseif($Option -ne "1" -or "2"){

Write-Host "No Licenses have been Assigned"
}