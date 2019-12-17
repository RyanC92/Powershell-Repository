# OU's
# OU=Computers,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org

#import the module for active directory into Powershell
Import-module activedirectory

#Directory selection for report export
Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}


$OrigLoc = Get-location

Set-location AD:

#assign Get-location to the variable $local
$local = Get-Location


#While the path of local is not equal to AD:\ go up a directory and update the location for variable $local
while($local.path -ne "AD:\"){

Set-Location ..

$local = Get-Location
$local.path
}

#Set the location of the powershell window to AD:\
Write-host "Changing Starting Location to Base AD:" -ForegroundColor Yellow
set-location ad:


#Prompt for options
Write-Host "Choose the location to go to to pull the report" -ForegroundColor Yellow
Write-Host "1. SOM" -ForegroundColor Yellow
Write-Host "2. PHI" -ForegroundColor Yellow
Write-Host "3. PIT" -ForegroundColor Yellow
Write-Host "4. Enter Your Own OU" -ForegroundColor Yellow

$Location = Read-Host "Location"


#Run your if variables, if for <location> run the report
if($Location -like "SOM" -or $Location -like "1"){

    Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
    $Directory = Get-FolderName   

    Set-location "OU=Computers,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org"
    Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "$($Directory)\Report_SOM_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
    cls
    Write-Host "Report Has Been Created. It is named Report_SOM_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv in $($Directory)" -ForegroundColor Green

    #if not the first location then this
    }elseif($Location -like "PHI" -or $Location -like "2") {

        Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
        $Directory = Get-FolderName   

        Set-location "OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "$($Directory)\Report_PHI_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        cls
        Write-Host "Report Has Been Created. It is named Report_PHI_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv in $($Directory)" -ForegroundColor Green

    }elseif($Location -like "PIT" -or $Location -like "3") {
        
        Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
        $Directory = Get-FolderName   

        Set-location "OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "$($Directory)\Report_PIT_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        cls
        Write-Host "Report Has Been Created. It is named Report_PIT_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv in $($Directory)" -ForegroundColor Green
        
    
    }elseif($Location -like "4" -or $Location -like "OU"){

        Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
        $Directory = Get-FolderName   

        Write-host "Enter your custom OU (You can get this from the Distinguished Name of an asset) Example: OU=Computers,OU=City,OU=Region,OU=Offices,DC=Company,DC=Org"
        $CustLoc = Read-host "Location"
        
        $Custloc
        Set-location "$($CustLoc)"
        Get-Adcomputer -Filter * -Properties * | Select CN, LastLogonDate, Enabled, Description | Export-csv "$($Directory)\Report_Custom_LastLogonDate_$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv" -NoTypeInformation
        cls
        Write-Host "Report Has Been Created. It is named Report_Custom_LastLogonDate_$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv in $($Directory)" -ForegroundColor Green
        
        
    }else{


    }
   #if no options selected at beginning, exit


#Return to original location to re-execute if needed. 
Push-Location $Origloc