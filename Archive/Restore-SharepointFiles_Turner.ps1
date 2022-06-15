#Modify the URL For the site you are working with.

connect-pnponline -url 
$today = (Get-Date)
$restoreDate = $today.date.AddDays(-7)

#Get list of items to be restored - 5000 item limit 
#Modify the DeletedByEmail Value After -eq and the DirName after -like
Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq 'rcurran@tcco.com') -and ($_.Dirname -like "General")}  | select -last 4998 | Export-Csv c:\temp\restore.csv

#restore items - 5000 item limit
Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq 'rcurran@tcco.com') -and ($_.Dirname -like "General")}  | select -last 4998 | Restore-PnpRecyclebinItem -Force
