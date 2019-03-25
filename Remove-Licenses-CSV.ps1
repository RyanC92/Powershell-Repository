Write-Host "This will Remove All Licenses For Users Provided VIA CSV"
$CSVPath = Read-Host "Please Paste the full path to the CSV file (Including the file itself)"


$Option = Read-Host "1 To Remove User Licenses"

if($Option -eq "1"){

 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:VISIOCLIENT" }
 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:PROJECTCLIENT" }
 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:EXCHANGEDESKLESS" }
 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:EXCHANGESTANDARD" }
 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:OFFICESUBSCRIPTION" }
 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:EXCHANGEARCHIVE" }
 Import-CSV $CSVPath | foreach-Object { Set-MsolUserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:O365_BUSINESS" }

}

elseif($Option -ne "1"){

Write-Host "No Changes Were Made, Be More Careful Next Time."

}