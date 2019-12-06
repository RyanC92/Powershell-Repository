#OU's
# OU=Computers,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org
# 

#import the module for active directory into Powershell
Import-module activedirectory

$OrigLoc = Get-location

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
Write-host "Changing Starting Location to Base AD:" -ForegroundColor Yellow
set-location ad:
Get-location

#Prompt for options
Write-Host "Choose the location to go to to pull the report" -ForegroundColor Yellow
Write-Host "1. SOM" -ForegroundColor Yellow
Write-Host "2. PHI" -ForegroundColor Yellow
Write-Host "3. PIT" -ForegroundColor Yellow

$Location = Read-Host "Location"


#Run your if variables, if for <location> run the report
if($Location -like "SOM" -or $Location -like "1"){

    Set-location "OU=Computers,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org"
    Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "C:\CSV\Report_SOM_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    cls
    Write-Host "Report Has Been Created. It is named Report_SOM_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv" -ForegroundColor Green

    #if not the first location then this
    }elseif($Location -like "PHI" -or $Location -like "2") {

        Set-location "OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "C:\CSV\Report_PHI_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        cls
        Write-Host "Report Has Been Created. It is named Report_PHI_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv" -ForegroundColor Green

    }elseif($Location -like "PIT" -or $Location -like "3") {

        Set-location "OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "C:\CSV\Report_PIT_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        cls
        Write-Host "Report Has Been Created. It is named Report_PIT_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv" -ForegroundColor Green
        
    
    }else{
   #if no options selected at beginning, exit
}

#Return to original location to re-execute if needed. 
Push-Location $Origloc