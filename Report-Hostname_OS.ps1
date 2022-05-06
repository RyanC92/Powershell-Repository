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

#Set the location of the powershell window to AD:\
set-location ad:

Write-Host "Choose the location to go to to pull the report"
Write-Host "1. Excelsior Desktops"
Write-Host "2. Excelsior Laptops"
Write-Host "3. All"

$Location = Read-Host "Location"

if($Location -eq "Excelsior Laptops" -or $Location -eq "2") {
 
    Set-location ""
    Get-Adcomputer -Filter * -Properties * | Select Name, OperatingSystem | Export-csv "C:\CSV\Excelsior_Laptops$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    Write-Host "Report Has Been Created. It is named Excelsior_Laptops_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"
    
    #if a desktop run script
}elseif($Location -eq "Excelsior Desktops" -or $Location -eq "1"){
         
    Set-location ""
    Get-Adcomputer -Filter * -Properties * | Select Name, OperatingSystem | Export-csv "C:\CSV\Excelsior_Desktops$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    Write-Host "Report Has Been Created. It is named Excelsior_Desktops_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"
    
}elseif($Location -eq "All" -or $Location -eq "3"){
        
    Set-location ""
    Get-Adcomputer -Filter * -Properties * | Select Name, OperatingSystem | Export-csv "C:\CSV\Excelsior_Computers_All_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    Write-Host "Report Has Been Created. It is named Excelsior_computers_all_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"
    
    #if none then exit
}else{
         
        }
    #if no options selected at beginning, exit
    
    
      
