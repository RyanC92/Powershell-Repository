Import-module activedirectory

Set-location AD:


#Write an "Are you sure" option. 



#assign Get-location to the variable $local
$local = Get-Location


#While the path of local is not equal to AD:\ go up a directory and update the location for variable $local


$HN = Import-csv C:\CSV\DeletefromAD.csv

$HN
$Choice = Read-Host "Are you Sure you want to Delete these? "


if($Choice -eq "Yes" -or "Y" -or "1"){
    while($local.path -ne "AD:\"){

        cd ..
        
        $local = Get-Location
        $local.path
        }
    
    Set-location "OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"
    
    ForEach ($HNs in $HN){

        $tc = test-connection $Hns.Hostname -quiet -count 1

        if($tc -eq $False){
        

            Try{

                Remove-Adcomputer -Identity $HNs.Hostname -ErrorAction Stop

            }
            
            catch [System.Exception] {

                Write-host "$($HNs.Hostname) Doesn't exist"

            }
        
        }
    
    
    }


}else{

    "Aborted"

}

Push-location C:\Powershell-Repository
