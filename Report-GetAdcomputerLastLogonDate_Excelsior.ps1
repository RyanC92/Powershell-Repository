#OU's
# OU=Laptops,OU=US_Meriden_CT,OU=Users_And_Computers,DC=medline,DC=com
# OU=US_Meriden_CT,OU=Users_And_Computers,DC=medline,DC=com
# OU=Laptops,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com
# OU=Desktops,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com
# OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"

#import the module for active directory into Powershell
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

#Prompt for options
Write-Host "Choose the location to go to to pull the report"
Write-Host "1. Meriden"
Write-Host "2. Excelsior"
Write-Host ""

$Location = Read-Host "Location"


#Run your if variables, if for <location> run the report
if($Location -eq "Meriden" -or $Location -eq "1"){

    Set-location "OU=Laptops,OU=US_Meriden_CT,OU=Users_And_Computers,DC=medline,DC=com"
    Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled | Export-csv "C:\CSV\Meriden_Laptops$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    cls
    Write-Host "Report Has Been Created. It is named Meriden_Laptops_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"

#if not the first location then this
}elseif($Location -eq "Excelsior" -or $Location -eq "2") {
#prompt for device type
    Write-Host "1. Laptop, 2. Desktop or 3. All?"
    $ExcLoc = Read-Host "Device Type?"
    #if a laptop then run script
    if($ExcLoc -eq "Laptop" -or $ExcLoc -eq "1"){
     
        Set-location "OU=Laptops,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled | Export-csv "C:\CSV\Excelsior_Laptops$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        Write-Host "Report Has Been Created. It is named Excelsior_Laptops_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"

       #if a desktop run script
    }elseif($ExcLoc -eq "Desktop" -or $ExcLoc -eq "2"){
     
        Set-location "OU=Desktops,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled 
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled | Export-csv "C:\CSV\Excelsior_Desktops$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        Write-Host "Report Has Been Created. It is named Excelsior_Desktops_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"

    }elseif($ExcLoc -eq "All" -or $ExcLoc -eq "3"){
    
        Set-location "OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"
        Get-Adcomputer -Filter * -Properties * | Select CN, Created, LastLogonDate, Enabled, LogonCount, Description 
        Get-Adcomputer -Filter * -Properties * | Select CN, Created, LastLogonDate, Enabled, LogonCount, Description | Export-csv "C:\CSV\Excelsior_Computers_All_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        Write-Host "Report Has Been Created. It is named Excelsior_computers_all_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv"

       #if none then exit
    }else{
     
    }
    #if no options selected at beginning, exit
}else{
   
}

Push-Location C:\Powershell-Repository
