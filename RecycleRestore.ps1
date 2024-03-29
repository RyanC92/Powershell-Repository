<#
Required Module:  
Install-Module SharePointPnPPowerShellOnline
Credit to : https://lazyadmin.nl/powershell/restore-recycle-bin-sharepoint-online-with-powershell/
Credit to : https://github.com/joseinazusa/powershell-recursive-folder-restore/blob/master/recursive-recyclebin-restore.ps1#L3
I found lazyadmin which got me to Jose's excellent work and modified his script into a function which takes arguments for 
maxrows to return, a date range to search, and a "culprit" user for a massive delete action.  
Lazy Admin's guidance gave me the ideas for parsing dates and deleters.
Jose's code works better for when a specific folder needs to be restored.
#>


#Usage example.  Date/Time must be in specific M/d/yyyy H:m format. 6/1/2020 14:13
Import-Module "C:\powershell-repository\RecycleRestore.ps1" -force
#Restore-RecycleBin -siteUrl https://tcco.sharepoint.com/sites/PANJFinance518 -newerdate '12/15/2021 00:00' -olderDate '12/5/2021 20:00' -delEmail srowles@tcco.com -maxRows 100000

function Restore-RecycleBin 
{
    param ($siteUrl, $maxRows, $batchSize, $newerDate, $olderDate, $delEmail)

    if ($newerDate -eq $null -and $olderDate -eq $null -and $delEmail -eq $null) {
        Write-Host "No filter parameters supplied.  Terminating function."
        End
    }

    #Connect to Sharepoint Site
    Connect-PnPOnline -Url $siteUrl -interactive
    <#
    -UseWebLogin used for 2 factor Auth.  You can remove if you don't have MFA turned on
    Connect-PnPOnline -UseWebLogin -Url  $siteUrl
    #>

    $today = (Get-Date)
    if ($maxRows -eq $null) { $maxRows = 10000 }
    if ($batchSize -eq $null) { $batchSize = 500 }

    #If any date parameter is supplied, parse to datetime, set default dates for omitted values, and check for email 
    if ($olderDate -ne $null -or $newerDate -ne $null) {

        #Parse olderDate, check format and set default if $null
        if ($olderDate -ne $null) {
            try { $olderDate=[Datetime]::ParseExact($olderDate, 'M/d/yyyy H:m', $null) }
            catch {
                Write-Error "Bad format in olderDate parameter.  Enter dates in M/d/yyyy H:m format using 24 hour time."
                End
            }
        }
        else {$olderDate = $today.addDays(-120) }

        #Parse newerDate, check format and set default if $null
        if ($newerDate -ne $null) {
            try { $newerDate=[Datetime]::ParseExact($newerDate, 'M/d/yyyy H:m', $null) }
            catch {
                Write-Error "Bad format in newerDate parameter.  Enter date in M/d/yyyy H:m format using 24 hour time."
                End
            }
        }
        else { $newerDate = $today }

        #Check for valid date order
        if (($olderDate -gt $newerDate) -or ($newerDate -lt $today.addDays(-120)) -or ($olderDate -gt $today)) {
            Write-Host "newerDate $newerDate must preceed olderDate $olderDate.  Inconsistent results. Terminating."
            End
        }

        #Fetch restoreSets
        if ($delEmail -eq $null) {
            Write-Host "Getting $maxRows RecycleBin items between $newerDate and $olderDate" 
            $restoreSet = Get-PnPRecycleBinItem -FirstStage -RowLimit $maxRows | Where-Object {($_.DeletedDate -lt $newerDate -and $_.DeletedDate -gt $olderDate)}
        }
        else {
            Write-Host "Getting $maxRows RecycleBin items between $newerDate and $olderDate deleted by $delEmail" 
            $restoreSet = Get-PnPRecycleBinItem -FirstStage -RowLimit $maxRows | Where-Object {($_.DeletedDate -gt $olderDate -and $_.DeletedDate -lt $newerDate) -and ($_.DeletedByEmail -eq $delEmail)}
        }
    }
    else {
        Write-Host "Getting $maxRows RecycleBin items deleted by $delEmail" 
        $restoreSet = Get-PnPRecycleBinItem -FirstStage -RowLimit $maxRows | Where-Object {$_.DeletedByEmail -eq $delEmail}
    }

    #Extract only needed parameters and sort by folders to minimize issues with existing folders
    $restoreList = $restoreSet | select Id, ItemType, LeafName, DirName
    $restoreList = $restoreList | Sort-Object -Property @{expression ='ItemType'; descending = $true},@{expression = "DirName"; descending = $false} , @{expression = "LeafName"; descending = $false} 

    #Batch restore $batchSize # of items
    #Set SPO API call path for restoration action
    $apiCall = $siteUrl + "/_api/site/RecycleBin/RestoreByIds"

    $restoreListCount = $restoreList.count
    Write-Host "Got $restoreListCount items to process"
    
    #Build batch list of Id's to pass into SPO API method
    $totalProcd = 0
    $leftToProcess = $restoreListCount - $totalProcd
    while($leftToProcess -gt 0){
        If($leftToProcess -lt $batchSize){$numToProcess = $leftToProcess} Else {$numToProcess = $batchSize}
        Write-Host -ForegroundColor Yellow "Building statement to restore the following $numToProcess files"
        $body = "{""ids"":["
        for($i=0; $i -lt $numToProcess; $i++){
            $cur = $totalProcd + $i
            $curItem = $restoreList[$cur]
            $Id = $curItem.Id
            Write-Host -ForegroundColor Green "Adding ", $curItem.ItemType, ": ", $curItem.DirName, "//", $curItem.LeafName
            $body += """" + $Id + """"
            If($i -ne $numToProcess - 1){ $body += "," }
        }
        $body += "]}"
        #Report list of Id's and submit to API for restoration
        Write-Host -ForegroundColor Yellow $body
        Write-Host -ForegroundColor Yellow "Performing API Call to Restore $numToProcess items from RecycleBin. $leftToProcess items remaining..."
        try {
            Invoke-PnPSPRestMethod -Method Post -Url $apiCall -Content $body | Out-Null
        }
        catch {
            Write-Error "Unable to Restore"     
        }
        $totalProcd += $batchSize
        $leftToProcess = $restoreListCount - $totalProcd
    }
    #Disconnect from SPO
    Disconnect-PnPOnline
}