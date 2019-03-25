Import-Module ActiveDirectory

Set-location AD:

while($local.path -ne "AD:\"){

cd ..

$local = Get-Location

}

Set-location "OU=Role,OU=Groups,OU=Special,DC=medline,DC=com"

cls

Get-ADgroup -Filter * | Where{ $_.Name -like "RG-Excelsior*"}  | select Name, DistinguishedName, GroupCategory, GroupScope |  Export-CSV "C:\CSV\Excelsior Role Groups - Exported $([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    cls
    Write-Host "Report Has Been Created. It is named Excelsior Role Groups - Exported $([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"