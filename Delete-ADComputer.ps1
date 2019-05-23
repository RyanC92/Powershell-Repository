Import-module activedirectory

Set-location AD:

#assign Get-location to the variable $local
$local = Get-Location


#While the path of local is not equal to AD:\ go up a directory and update the location for variable $local
while($local.path -ne "AD:\"){

cd ..

$local = Get-Location
$local.path
}

$HN = Import-csv C:\CSV\DeletefromAD.csv

Set-location "OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"

ForEach ($HNs in $HN){

    Remove-Adcomputer -Identity $HNs.Hostname

}
Push-location C:\Powershell-Repository
