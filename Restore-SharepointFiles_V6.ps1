<#Description:
Restore sharepoint online files that were previously deleted by a singular user
This process is not fast (about 1-2 files per second) but it'll do the job.
The Program will prompt for a few questions:
What the Sharepoint URL is. 
How many days back to search.
The Email Address of the user who deleted the files
The maximum amount of items to search for per cycle (this program will cycle until it gets down to 0 or it has files that cant be restored)

Author: Ryan Curran
#>

# Self-elevate the script if required
"Checking to for an elevated powershell session (Administrator)"
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
     Exit
    }
   }




#initialize variables
$backDate = '0'
$i = 1
$loop = 1

#Check if the old sharepoint module is installed if so, uninstall it then check for the PnP Powershell Module is installed, if not install it
if(Get-Module -ListAvailable -name Microsoft.Online.SharePoint.Powershell){
    Write-Host "Removing the Microsoft.Online.SharePoint.Powershell Module as it's a legacy module and has been replaced by PnP.Powershell - This process should run once but may take a few minutes (This requires powershell to be run as an Administrator)" -ForegroundColor Green
    
    Uninstall-Module -name Microsoft.Online.Sharepoint.Powershell -force -ErrorAction SilentlyContinue
    Install-module -name pnp.powershell -Force

}elseif(Get-Module  -ListAvailable -name PnP.Powershell){
    #Write-Host "PnP Powershell Module is Installed, checking for updates - This may take a few minutes.`n
    #Note: You may have to press Enter to continue." -ForegroundColor Green

    $pnp = Get-module -ListAvailable -name Pnp.Powershell | Select Version
    "Your PnP.Powershell Version is: $($pnp.version), if it is sub version 1.9. Please run 'update-module -name pnp.powershell'"

    <#$verCheck = Find-module -name pnp.powershell -Repository PSGallery | select Version
    "The Current Version of PnP.Powershell is: $($verCheck.Version). If they are equal, it will skip"
    
        if ($verCheck.version -gt $pnp.version){
            update-module -name pnp.powershell
        }else{
            "Your Version is up to date, moving on."
        }
    #>
             
}else{
    Write-Host "PnP Powershell Module isn't installed, Installing now. This may take a few minutes (This requires powershell to be run as an Administrator)" -ForegroundColor Green
    Install-module -name pnp.powershell
}

#Prompt for questions
do {
    
    $SPURL = Read-host "Please enter the URL of the site. Example: https://tcco.sharepoint.com/sites/SiteName `n `
    Site URL"

    if ($SPURL -eq "") {
        cls
        Write-Host "No input detected, please try again..."
        }else{
        }
}while ($SPURL -eq "")
cls

#Connect to SPOnline using the interactive window for MFA
Write-Host "Connecting to Sharepoint Online site: $SPURL, Please authenticate through the pop-up window"
Connect-Pnponline -url "$SPURL" -interactive


do {
    
    $delBy = Read-host "Please enter the email address of the user who deleted the items `n
    Email Address"

    if ($delBy -eq "") {
        cls
        Write-Host "No input detected, please try again..."
        }else{
        }
}while ($delBy -eq "")
cls

"Connected to: $SPURL"
"Searching by Deleted by Address: $delBy `n"

do {
    $searchDate = [int]::TryParse((Read-Host "Please enter how many days back from today you would like to go. If its to restore today, type 0 `n
        Days"), [ref]$backDate)

    if (-not $searchDate) {
        cls
        Write-Host "your input was not an number, please try again..."
    }else{

    }
} while (-not $searchDate)
cls

#Get todays date and subtract the backdays to get the date desired
$restoredate = ((Get-Date).Date.AddDays(-$backDate))

"Connected to: $SPURL"
"Searching by Deleted By Address: $delBy"
"Searching back: $backDate Days"
"Restore Date is set as: $restoreDate `n"

#Do a while loop until a number is submitted at or under 4998 items
DO{
    $qSize = Read-Host "How many items would you like per cycle. Note: Maximum limit per cycle is 4998 items `n
    Items"
}while ($qSize -lt '0' -AND $qSize -gt '4998')
cls

"Connected to: $SPURL"
"Searching by Deleted By Address: $delBy"
"Searching back: $backDate Days"
"Restore Date is set as: $restoreDate"
"Query Size: $qSize `n"

$Title = ""
$Info = Write-host "Final Question: Is there a specific directory to restore from?" -Foregroundcolor Yellow -Backgroundcolor Black
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Yes", "&2. No", "&3. Exit")
[int]$defaultchoice = 0
$opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
switch($opt)
{
0 { 
    Write-Host "Please Enter the Sub Directory of the Site to restore from. Ex: Shared Documents or General etc. " -Backgroundcolor Black -ForegroundColor Yellow
    $DirToRe = Read-Host "Sub Directory"

    Write-host "Beginning restore" -ForegroundColor Green
    #Get initial recycle bin items
    $RecycleBinitems = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*$delBy*") -and ($_.DirName -like "*$DirToRe*")} | select -last $qSize
    
    
    While($($RecycleBinitems.count) -notlike "0"){
    
        Foreach ($ID in $RecycleBinitems){
            
            $loop++

            Write-Progress -Activity "Restoring Files" -Status "Updating: $i of $($RecycleBinitems.count) of Loop $Loop"
            "Restoring $($ID.Title). File $i of $($RecyclebinItems.Count) of Loop $Loop"
            
            Try{ 
                Restore-PnPRecycleBinItem -Identity "$($ID.ID)"-force
            $i++ 
            }Catch{
                Write-host "$($ID.Title) Errored Out. This could be because the file already exists and will not overwrite." -ForegroundColor Red -BackgroundColor Black
            }
        }
    
            #re-query the recycling bin for the next set of items, reset $i and increment $loop for tracking
            $RecycleBinitems = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*$delBy*") -and ($_.DirName -like "*$DirToRe*")} | select -last $qSize
            $i=1 
            $total += $Recyclebinitems.count
    }
}
1 { 
    Write-host "Skipping the Sub Directory and moving on to the restore" -ForegroundColor Green
    #Get initial recycle bin items
    $RecycleBinitems = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*$delBy*")} | select -last $qSize
    
    
    While($($RecycleBinitems.count) -notlike "0"){
    
        Foreach ($ID in $RecycleBinitems){
            
            $loop++

            Write-Progress -Activity "Restoring Files" -Status "Updating: $i of $($RecycleBinitems.count) of Loop $Loop"
            "Restoring $($ID.Title). File $i of $($RecyclebinItems.Count) of Loop $Loop"
            
            Try{ 
                Restore-PnPRecycleBinItem -Identity "$($ID.ID)"-force
            $i++ 
            }Catch{
                Write-host "$($ID.Title) Errored Out. This could be because the file already exists and will not overwrite." -ForegroundColor Red -BackgroundColor Black
            }
        }
    
            #re-query the recycling bin for the next set of items, reset $i and increment $loop for tracking
            $RecycleBinitems = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*$delBy*")} | select -last $qSize
            $i=1 
            $total += $Recyclebinitems.count
    }
}
2 { Write-Host "Exit" -ForegroundColor Red}
}    "`n Restore is complete. `n
Restored $total files or folders over $loop loops (Numbers may not accurately portray real count as it is counting folders which may contain files and not account for the individual files)" 
pause
