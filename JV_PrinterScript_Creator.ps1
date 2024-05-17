#Created by Ryan Curran
# 5/16/24
#######################

Add-type -AssemblyName PresentationCore, PresentationFramework

#Variables

$entries = Get-githubcontent -OwnerName TurnerJVDriverRepo -RepositoryName TCCODrivers | Select-Object -ExpandProperty Entries
$indexedEntries = $entries | Select-Object @{Name="#"; Expression={[array]::IndexOf($entries, $_) + 1}}, name, Path, @{Name = "File Size"; Expression={"$([math]::Round($_.size / 1MB)) MB"}}, download_url
$indexedEntries | Format-Table -Property "#", name, "File Size", download_url -AutoSize

$Printer entry



$scriptcontent = @"

#Created by Ryan Curran
# 5/16/24
#######################

#---------------------Static Values---------------------------
#Dont change these values
$githost = "github.com"
$gitpath = "https://github.com/TurnerJVDriverRepo/TCCODrivers/raw/main/"
$tcpipPort = "9100"
$userpath = "$env:userprofile\Downloads\"
#---------------------End Static Values-----------------------

#Printer IP Address
$printerIP =  "192.168.252.240"
#The name the end user will see for their printer entry
$printerDisplayname = "Princeton - Ricoh C6004"
#DriverName can be found inside of the "INF" file for the driver
$driverName = "RICOH MP C6004 PCL 6"
#Get the name of the ZIP from github (Example: Ricoh_C8003.zip)
$driverZipName = "Ricoh C6004.zip"


#Build the URL
$driverZipLink = $driverZipName -replace ' ', '%20'
$driverURL = $gitpath+$driverZipLink

$tc = test-connection $githost -Count 1 -Quiet
if ($tc -eq $True){

    "Connection Test Success"
}else{
    [System.windows.messagebox]::show("Connection test failed, please make sure you are connected to the internet")
    exit
}

#Window Title
$host.UI.RawUI.WindowTitle = "Installing Printer $PrinterDisplayName"

Write-Host "Installing $printerDisplayName Printer, Please Wait......`n" -ForegroundColor Green

Write-Host "[=======25               ]`n" -ForegroundColor Green
Write-host "Downloading the printer driver from the external repo (Github)`n" -ForegroundColor Green

#CURL Driver from Github
Invoke-WebRequest -Uri $driverURL -Outfile $env:userprofile\Downloads\Driver.zip

Write-Host "[===========65           ]`n" -ForegroundColor Green
Write-Host "Extracting the Printer Driver`n"
$dirtest = Get-Childitem $userpath | select Name

if ($Dirtest.name -contains "Driver"){
    "Driver folder detected in $userpath, renaming to driver.bak"
    mv $userpath\driver $userpath\driver.bak
    "Expanding driver archive"
    Expand-Archive -Path $userpath\Driver.zip $userpath\Driver -Force
}else{
    "No Driver folder detected in $userpath, expanding driver archive"
    Expand-Archive -Path $userpath\Driver.zip $userpath\Driver -Force
}

Write-Host "`n[================75        ]`n" -ForegroundColor Green
Write-Host "Creating the Printer port`n" -ForegroundColor Green

#Creating Printer TCPIP Port
CSCRIPT /nologo $env:windir\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r "$printerIP" -o raw -n 9100 -h "$printerIP"

Write-Host "Printer port created with IP $printerIP`n" -ForegroundColor Green

Write-Host "`n[=====================90   ]`n" -ForegroundColor Green
Write-Host "Creating Printer Entry $printerDisplayName`n" -ForegroundColor Green

rundll32 printui.dll,PrintUIEntry /if /n "$PrinterDisplayName" /b "$PrinterDisplayName" /f "$userpath\Driver\Ricoh C6004\oemsetup.inf " /r "$printerIP" /m "$driverName"

Write-Host "`n[==========================100]`n" -ForegroundColor Green
[System.windows.messagebox]::show("Printer $PrinterDisplayName is now Installed")

"@
Set-Content -Path ".\JV Printer Script.ps1" -Value $ScriptContent
