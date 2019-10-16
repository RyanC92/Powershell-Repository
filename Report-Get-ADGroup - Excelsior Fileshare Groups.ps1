Import-Module ActiveDirectory

Set-location AD:

while($local.path -ne "AD:\"){

cd ..

$local = Get-Location

}

Set-location "OU=FileShares,OU=Security,OU=Groups,OU=Special,DC=medline,DC=com"

cls

Get-ADgroup -Filter * | Where{ $_.Name -like "SD-FS-USNJFS001*" -or $_.Name -like "SD-FS-NEP*"}  | select Name, DistinguishedName, GroupCategory, GroupScope |  Export-CSV "C:\CSV\Excelsior Fileshare Groups - Exported $([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    cls
    Write-Host "Report Has Been Created. It is named Excelsior Fileshare Groups - Exported $([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"