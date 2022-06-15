#Modify the URL For the site you are working with.
cls
Write-Host "Please Enter The URL For The Site to Connect to. Ex: " -Backgroundcolor Black -ForegroundColor Yellow
$RestoreSite = Read-Host "URL"
connect-pnponline -url "$($RestoreSite)" -interactive
$today = (Get-Date)
Write-host "How many days back do you need to restore?" -Backgroundcolor Black -ForegroundColor Yellow
$BackDate = Read-Host "Go Back How Many Days?"
$restoreDate = $today.date.AddDays(-$Backdate)
"Your Restore Date is from $($RestoreDate) to present"

#Get list of items to be restored - 5000 item limit 
#Export goes to C:\Temp\Restore.csv

$Title = ""
Write-host "Please choose to either scan and export a list of recoverable files to a CSV or to restore the files?" -Foregroundcolor Yellow -Backgroundcolor Black
$Info = $Null

$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Scan and Export", "&2. Restore", "&3. Both (Scan, Export & Restore)", "&4. Quit")
[int]$defaultchoice = 0
$opt = $host.UI.PromptForChoice($Title, $Info, $Options,$defaultchoice)
switch($opt)
{
0 { 
    Write-Host "Scan and Export" -ForegroundColor Green
    Write-Host "Please Enter the email address of the Deleted By User" -Backgroundcolor Black -ForegroundColor Yellow
    $UserDelby = Read-host "Email"
    "You Entered $($UserDelby)"

    Write-Host "Please Enter the Sub Directory of the Site to restore from. Ex: Shared Documents or General etc. " -Backgroundcolor Black -ForegroundColor Yellow
    $DirToRe = Read-Host "Sub Directory"
    "You Entered $($DirToRe)"

    Get-PNPRecyclebinitem |  ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq "$($UserDelby)") -and ($_.Dirname -like "*$($DirToRe)*")}  | select -last 4000 | Export-Csv c:\temp\restore.csv

    }
1 { 
    Write-Host "Restore" -ForegroundColor Green
    Write-Host "Please Enter the email address of the Deleted By User" -Backgroundcolor Black -ForegroundColor Yellow
    $UserDelby = Read-host "Email"
    "You Entered $($UserDelby)"

    Write-Host "Please Enter the Sub Directory of the Site to restore from. Ex: Shared Documents or General etc. " -Backgroundcolor Black -ForegroundColor Yellow
    $DirToRe = Read-Host "Sub Directory"
    "You Entered $($DirToRe)"

    #restore items - 5000 item limit
    Get-PNPRecyclebinitem |  Foreach-object {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq "$($UserDelby)") -and ($_.Dirname -like "*$($DirToRe)*")}  | select -last 4000 | Restore-PnpRecyclebinItem -Force

}
2 { 
    Write-Host "Both" -ForegroundColor Green
    Write-Host "Please Enter the email address of the Deleted By User" -Backgroundcolor Black -ForegroundColor Yellow
    $UserDelby = Read-host "Email"
    "You Entered $($UserDelby)"

    Write-Host "Please Enter the Sub Directory of the Site to restore from. Ex: Shared Documents or General etc. " -Backgroundcolor Black -ForegroundColor Yellow
    $DirToRe = Read-Host "Sub Directory"
    "You Entered $($DirToRe)"

    #export items - 5000 Item Limit
    Get-PNPRecyclebinitem |  ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*$($UserDelby)*") -and ($_.Dirname -like "*$($DirToRe)*")}  | select -last 4000 | Export-Csv c:\temp\restore.csv
    #restore items - 5000 item limit
    Get-PNPRecyclebinitem |  ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*$($UserDelby)*") -and ($_.Dirname -like "*$($DirToRe)*")}  | select -last 4000 | Restore-PnpRecyclebinItem -Force

}
3 {Write-Host "Quit" -ForegroundColor Green}
}


<#
Get-PNPRecyclebinitem |  ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq 'deanna.broussard@perryhomes.com') -and ($_.Dirname -like 'Shared Documents or General etc. ')}  | select -last 4000 | Export-Csv c:\temp\restore.csv

#restore items - 5000 item limit
Get-PNPRecyclebinitem |  ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq 'deanna.broussard@perryhomes.com') -and ($_.Dirname -like 'Shared Documents or General etc. ')}  | select -last 4000 | Restore-PnpRecyclebinItem -Force
#>


<# Enter this and call to it as Get-Foldername to open a dialog box to choose a file or choose a location, you can swap this with the Export-csv location (Example $Loc = Get-Foldername and change Export-CSV $Loc)
Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}
#>
