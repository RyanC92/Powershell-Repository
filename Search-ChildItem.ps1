<#
Author: Ryan Curran
#>

# Self-elevate the script if required
Write-Host "Checking to for an elevated powershell session (Administrator)" -ForegroundColor Green
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
     Exit
    }
   }

#initialize variables

$SearchPath = ''
$SearchFold = ''
$PermUser = ''
$PermLevels = ''
$Include = ''

#Check if the old sharepoint module is installed if so, uninstall it then check for the PnP Powershell Module is installed, if not install it
if(Get-Module -ListAvailable -name NTFSSecurity){
    Write-Host "You already have NTFSSecurity, Moving on... `n" -ForegroundColor Green
    

}else{
    Write-Host "NFTSSecurity Module isn't installed, Installing now. This may take a few minutes (This requires powershell to be run as an Administrator)" -ForegroundColor Green
    Install-module -name NTFSSecurity -force
}

do {

    Write-Host "Please Enter the Path of the directory you want to search."
    Write-Host "Example: '\\PITFILE1\Data\Accounting\Files\' `n"
    
    $SearchPath = Read-Host "Enter Here"


    
    if ($SearchPath -eq ""){

    
        Write-Host "`n No Input Detected, Please Try Again..." -ForegroundColor Red
    }else{

    }
}while($SearchPath -eq "")
#cls

$Title = ""
$Info = Write-host "Are you searching for a file, directory or both? `n" -Foregroundcolor Yellow -Backgroundcolor Black
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. File (and Directory)", "&2. Directory (Only)", "&3. Exit")
[int]$defaultchoice = '0'
$opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
switch($opt)
{
    1 { 

        Write-host "Please enter the name of the file, file type or directory you are searching for"
        Write-Host "This could be File.docx or *.pdf or just a name 'Accounting' etc. Keep in mind, the more broad the search the longer it will take. `n "
        $Include = Read-Host "Enter Here "

        Write-Host "You Entered: $SearchPath"
        Write-Host "You are searching for: '$Include'"

        $Results = Get-childitem -Path "$SearchPath" -recurse -include "$Include" | Select Name, FullName, Attributes
        $Results

        Write-Host "Exporting to C:\Temp\Export_ChildItems-$((Get-Date).ToString('MM-dd-yyyy_hh-mm')).csv"

        $Results | Export-csv "C:\Temp\Export_ChildItems-$((Get-Date).ToString('MM-dd-yyyy_hh-mm')).csv" -notypeinformation

        Write-Host "Done!" -ForegroundColor Green
    }
    2 {

        Write-host "Please enter the name of the directory you are searching for `n"
        $Include = Read-host "Enter Here"

        Write-Host "You Entered: $SearchPath"
        Write-Host "You are searching for: '$Include'"

        $Results = Get-childitem -Path "$SearchPath" -recurse -directory -include "$Include" | Select Name, FullName, Attributes
        $Results

        Write-Host "Exporting to C:\Temp\Export_ChildItems-$((Get-Date).ToString('MM-dd-yyyy_hh-mm')).csv"

        $Results | Export-csv "C:\Temp\Export_ChildItems-$((Get-Date).ToString('MM-dd-yyyy_hh-mm')).csv" -notypeinformation

        Write-Host "Done!" -ForegroundColor Green

    }
    3 {

        "Exiting"
        exit
    }
}





