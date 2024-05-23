#Created by Ryan Curran
# 5/16/24
#######################

Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!" -ForegroundColor DarkGreen
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}

#Check Script is running with Elevated Privileges
Check-RunAsAdministrator

#Install PowershellForGithub Module to pull in Github directory
Install-Module -Name PowerShellForGitHub -confirm:$False -force 
Add-type -AssemblyName PresentationCore, PresentationFramework

#Variables
$entries = Get-githubcontent -OwnerName TurnerJVDriverRepo -RepositoryName TCCODrivers | Select-Object -ExpandProperty Entries
$indexedEntries = $entries | Select-Object @{Name="#"; Expression={[array]::IndexOf($entries, $_) + 1}}, name, Path, @{Name = "File Size"; Expression={"$([math]::Round($_.size / 1MB)) MB"}}, download_url
$indexedEntries | Format-Table -Property "#", name, "File Size", download_url -AutoSize
"------------------------------------------------------`n"
Write-host "Turner JV / Owners Network Printer Creator `n
Enter the required information below and a printer script for JV Printers will be created in Powershell.`n
This is for printers that are on the Turner Guest VLAN with a 192 IP or on Owners networks." -ForegroundColor Green -BackgroundColor Black
"------------------------------------------------------`n"
$printerIP = Read-Host "Enter The Printer IP"
"------------------------------------------------------`n"
$printerDisplayName = Read-Host "Enter the display name of the printer (as it will show in their print queue)"
"------------------------------------------------------`n"
$driverName = Read-Host 'Please Enter the driver name (DriverName can be found inside of the "INF" file for the driver)'
"------------------------------------------------------`n"

$scriptcontent = @"

#Created by Ryan Curran
# 5/16/24
#######################

#---------------------Static Values---------------------------
#Dont change these values
$tcpipPort = "9100"
$userpath = "$env:userprofile\Downloads\"
#---------------------End Static Values-----------------------


$tc = test-connection  -Count 1 -Quiet
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
