#Connect to Module
$errorOccured = $False
try { 
    Get-installedmodule -name Microsoft.Online.Sharepoint.Powershell 
    $errorOccured = $False
}
catch { 
    Install-Module SharePointPnPPowerShellOnline
    $errorOccured = $True
}
if(!$errorOccured) {
    "Sharepoint Module Is Already Installed."
}


connect-pnponline -url https://tcco.sharepoint.com/sites/PANJFinance518 -interactive
$today = (Get-Date)
$restoreDate = $today.date.AddDays(-0)

$RecylceBinItems = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*srowles@tcco.com*")} | select -last 4998
$RecycleBinitemsNL = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*srowles@tcco.com*")}

#Get list of items to be restored - 5000 item limit
$RecylceBinItems | Export-Csv c:\temp\restore.csv -NoTypeInformation



#restore items - 5000 item limit
$RecylceBinItems | Restore-PnpRecyclebinItem -Force




#Get list of items to be restored - no document limit
$RecylceBinItemsNL | Export-Csv c:\temp\restore.csv -NoTypeInformation



# restore documents - no document limit
$RecylceBinItemsNL | Restore-PnpRecyclebinItem -Force