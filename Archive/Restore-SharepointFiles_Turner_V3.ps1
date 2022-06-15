# USE AT YOUR OWN RISK (Standard Disclaimer)

# This script was create to recursively restore a folder in the 
# first stage recycle bin when you have too many items in your Recycle Bin 
# Getting "The attempted operation is prohibited because it exceeds the list view threshold enforce by administrator" Error


# Required Module:  

$errorOccured = $False
try { 
    Get-installedmodule -name Microsoft.Online.Sharepoint.Powershell 
    $errorOccured = $true
}
catch { Install-Module SharePointPnPPowerShellOnline }
if(!$errorOccured) {
    "Sharepoint Module Is Already Installed."
}

#CHANGE FOLLOWING VARIABLES TO MATCH YOUR ENVIRONMENT
# YOUR SHAREPOINT SITE
$siteUrl = "
# The Folder to Restore - Full Path
$directoryToRestore = 'Shared Documents\General'

$today = (Get-Date)
Write-host "How many days back do you need to restore?" -Backgroundcolor Black -ForegroundColor Yellow
$BackDate = Read-Host "Go Back How Many Days?"
$restoreDate = $today.date.AddDays(-$Backdate)
# A number higher than your count in the recyclebin
# You can use a high number, just know it will take longer to get 
# the restoreSet
$maxRows = 400000


#  -UseWebLogin used for 2 factor Auth.  You can remove if you don't have MFA turned on
Connect-PnPOnline -Url  $siteUrl

$restoreSet = Get-PnPRecycleBinItem -FirstStage -RowLimit $maxRows | Where-Object {($_."Dirname" -Like $directoryToRestore + '/*' -or $_."Dirname" -Eq $directoryToRestore) -and ($_.DeletedByEmail -eq "jmramos@tcco.com") -and ($_.DeletedDate -GT "$RestoreDate")} 
$restoreSet = $restoreSet | Sort-Object -Property @{expression ='ItemType'; descending = $true},@{expression = "DirName"; descending = $false} , @{expression = "LeafName"; descending = $false} 

$restoreSet.Count 
# Batch restore up to 200 at a time
$restoreList = $restoreSet | select Id, ItemType, LeafName, DirName
$apiCall = $siteUrl + "/_api/site/RecycleBin/RestoreByIds"
$restoreListCount = $restoreList.count
$start = 0
$leftToProcess = $restoreListCount - $start
while($leftToProcess -gt 0){
    If($leftToProcess -lt 200){$numToProcess = $leftToProcess} Else {$numToProcess = 200}
    Write-Host -ForegroundColor Yellow "Building statement to restore the following $numToProcess files"
    $body = "{""ids"":["
    for($i=0; $i -lt $numToProcess; $i++){
        $cur = $start + $i
        $curItem = $restoreList[$cur]
        $Id = $curItem.Id
        Write-Host -ForegroundColor Green "Adding ", $curItem.ItemType, ": ", $curItem.DirName, "//", $curItem.LeafName
        $body += """" + $Id + """"
        If($i -ne $numToProcess - 1){ $body += "," }
    }
    $body += "]}"
    Write-Host -ForegroundColor Yellow $body
    Write-Host -ForegroundColor Yellow "Performing API Call to Restore items from RecycleBin..."
    try {
        Invoke-PnPSPRestMethod -Method Post -Url $apiCall -Content $body | Out-Null
    }
    catch {
        Write-Error "Unable to Restore"     
    }
    $start += 200
    $leftToProcess = $restoreListCount - $start
}
