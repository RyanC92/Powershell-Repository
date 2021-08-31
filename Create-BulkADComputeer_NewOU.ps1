#Recreate Computer names in new OU

$OldOU = Read-host "Enter old OU path Example: OU=Computers,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org"
$NewOU = Read-Host "Enter New OU Path Example: OU=Computers,OU=NJ,OU=North East,OU=Offices,DC=tcco,DC=org"

$OldAD = Get-adcomputer -searchbase "$OldOU" -Filter {name -like }
