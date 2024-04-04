# OU's
# OU=Computers,OU=Somerset,OU=North East,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org
# OU=Computers,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org

<#$MyCredential = new-object psobject -property @{
    Username = $null
    Password = $null
}
$Mycredential.Username = Read-host "Enter Username"
$Mycredential.Password = Read-host "Enter your password"
#>

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
Write-Host "1. NJO" -ForegroundColor Yellow
Write-Host "2. PHI" -ForegroundColor Yellow
Write-Host "3. PIT" -ForegroundColor Yellow
Write-Host "4. MAH" -ForegroundColor Yellow
Write-host "5. Enter Your Own OU" -ForegroundColor Yellow

$Location = Read-Host "Location"

Write-host "Select Your Export Directory" -ForegroundColor Yellow -BackgroundColor Black
$Directory = Get-FolderName   

#set i for iterations
$i = 0

#Run your if variables, if for <location> run the report
if($Location -like "SOM" -or $Location -like "1"){

    Set-location "OU=Computers,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org"
    $PCS = Get-adcomputer -filter * | Select Name

    "$($PCS.name.count) PCs have been found in this OU... Processing."

    ForEach ($PC in $PCS){
        #Increment $i from 0 to get a count
        $i++
        #Show progress of the count
        Write-Progress -Activity "Gathering WMIC Information" -Status "Processed: $i of $($PCs.count)"

        $tp = Test-Connection -ComputerName $PC.name -quiet -Count 1

        if($tp -eq $True){

            Write-host "$($PC.Name) is live, pulling information" -foregroundcolor Green
            $Bios = get-wmiobject Win32_bios -Computername $PC.Name -Erroraction SilentlyContinue | Select PSComputerName, __Class, Manufacturer, Serialnumber, Version `
                |  Export-csv "$($Directory)\WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append -NoTypeInformation
            "Processed $($PC.Name)"

        }else{
            Write-Host "$($PC.Name) is Offline, Skipping - Failed hostnames will be exported. "
            $PC | Export-csv "$($Directory)\SOM_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append -NoTypeInformation
        }

    }
        
    Write-Host "Report Has Been Created. It is named WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv in $($Directory)" -ForegroundColor Green
    Write-Host "Failed PCs have been exported to $($Directory)\SOM_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv"
    
    #if not the first location then this (and so on)
    }elseif($Location -like "PHI" -or $Location -like "2") {

        Set-location "OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org"
        $PCS = Get-adcomputer -filter * | Select Name
    
        "$($PCS.name.count) PCs have been found in this OU... Processing."

        ForEach ($PC in $PCS){

            #Increment $i from 0 to get a count
            $i++
            #Show progress of the count
            Write-Progress -Activity "Gathering WMIC Information" -Status "Processed: $i of $($PCs.count)"

            $tp = Test-Connection -ComputerName $PC.name -quiet -Count 1
    
            if($tp -eq $True){
               
                Write-host "$($PC.Name) is live, pulling information" -foregroundcolor Green
                $Bios = get-wmiobject Win32_bios -Computername $PC.Name -Erroraction SilentlyContinue | Select PSComputerName, __Class, Manufacturer, Serialnumber, Version `
                    |  Export-csv "$($Directory)\WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append -NoTypeInformation
                "Processed $($PC.Name)"
            
            }else{
                Write-Host "$($PC.Name) is Offline, Skipping - Failed hostnames will be exported. " -foregroundcolor Red
                $PC | Export-csv "$($Directory)\PHI_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append
            }
        
        }
                
        Write-Host "Report Has Been Created. It is named WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv in $($Directory)" -ForegroundColor Green
        Write-Host "Failed PCs have been exported to $($Directory)\PHI_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv"
        
    }elseif($Location -like "PIT" -or $Location -like "3") {

        Set-location "OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org"
        $PCS = Get-adcomputer -filter * | Select Name

        "$($PCS.name.count) PCs have been found in this OU... Processing."

        ForEach ($PC in $PCS){
            
            #Increment $i from 0 to get a count
            $i++
            #Show progress of the count
            Write-Progress -Activity "Gathering WMIC Information" -Status "Processed: $i of $($PCs.count)"

            $tp = Test-Connection -ComputerName $PC.name -quiet -Count 1
            
            if($tp -eq $True){
               
                Write-host "$($PC.Name) is live, pulling information" -foregroundcolor Green
                $Bios = get-wmiobject Win32_bios -Computername $PC.Name -Erroraction SilentlyContinue | Select PSComputerName, __Class, Manufacturer, Serialnumber, Version `
                    |  Export-csv "$($Directory)\WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append -NoTypeInformation
                "Processed $($PC.Name)"

            }else{
                Write-Host "$($PC.Name) is Offline, Skipping - Failed hostnames will be exported. " -foregroundcolor Red
                $PC | Export-csv "$($Directory)\PIT_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append
            }

        }
            
        Write-Host "Report Has Been Created. It is named WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv in $($Directory)" -ForegroundColor Green
        Write-Host "Failed PCs have been exported to $($Directory)\PIT_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv"
        
    }elseif($Location -like "MAH" -or $Location -like "4"){

        Set-location "OU=Computers,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org"
        $PCS = Get-adcomputer -filter * | Select Name

        "$($PCS.name.count) PCs have been found in this OU... Processing."

        ForEach ($PC in $PCS){
        
            #Increment $i from 0 to get a count
            $i++
            #Show progress of the count
            Write-Progress -Activity "Gathering WMIC Information" -Status "Processed: $i of $($PCs.count)"
        
            $tp = Test-Connection -ComputerName $PC.name -quiet -Count 1
    
            if($tp -eq $True){

                Write-host "$($PC.Name) is live, pulling information" -foregroundcolor Green
                $Bios = get-wmiobject Win32_bios -Computername $PC.Name -Erroraction SilentlyContinue | Select PSComputerName, __Class, Manufacturer, Serialnumber, Version `
                    |  Export-csv "$($Directory)\WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append -NoTypeInformation
                "Processed $($PC.Name)"
            
            }else{
                Write-Host "$($PC.Name) is Offline, Skipping - Failed hostnames will be exported. " -foregroundcolor Red
                $PC | Export-csv "$($Directory)\MAH_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append
            }


        }
                        
        Write-Host "Report Has Been Created. It is named WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv in $($Directory)" -ForegroundColor Green
        Write-Host "Failed PCs have been exported to $($Directory)\MAH_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv"
        
    }elseif($Location -like "OU" -or $Location -like "5") {
    
        Write-host "Enter your custom OU (You can get this from the Distinguished Name of an asset) Example: 'OU=Computers,OU=City,OU=Region,OU=Offices,DC=Company,DC=Org'"
        $CustLoc = Read-host "Location"
        
        $Custloc
        Set-location "$($CustLoc)"
        $PCS = Get-adcomputer -filter * | Select Name

        "$($PCS.name.count) PCs have been found in this OU... Processing."

        ForEach ($PC in $PCS){
            
            #Increment $i from 0 to get a count
            $i++
            #Show progress of the count
            Write-Progress -Activity "Gathering WMIC Information" -Status "Processed: $i of $($PCs.count)"
            
            $tp = Test-Connection -ComputerName $PC.name -quiet -Count 1
    
            if($tp -eq $True){
                
                Write-host "$($PC.Name) is live, pulling information" -foregroundcolor Green
                $Bios = get-wmiobject Win32_bios -Computername $PC.Name -Erroraction SilentlyContinue | Select PSComputerName, __Class, Manufacturer, Serialnumber, Version `
                    | Export-csv "$($Directory)\WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append -NoTypeInformation
                "Processed $($PC.Name)"

            
            }else{
                Write-Host "$($PC.Name) is Offline, Skipping - Failed hostnames will be exported. " -foregroundcolor Red
                $PC | Export-csv "$($Directory)\Custom_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv" -append
            }


        }
        
        Write-Host "Report Has Been Created. It is named WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv in $($Directory)" -ForegroundColor Green
        Write-Host "Failed PCs have been exported to $($Directory)\Custom_Failed_WMIC_Report_$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv"

    }else{


    }
   #if no options selected at beginning, exit


#Return to original location to re-execute if needed. 
Push-Location $Origloc