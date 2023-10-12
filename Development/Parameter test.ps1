#Parameters
$SiteURL = "https://tcco.sharepoint.com/sites/CFCPayrollDepartment"
$ListName = "Trade Payroll - Retrieve from CFC"
$CSVFile = "C:\Temp\FolderStats.csv"
 
#Connect to SharePoint Online
Connect-PnPOnline $SiteURL -Interactive
  
#Get the list
$List = Get-PnPList -Identity $ListName
 
#Get Folders from the Library - with progress bar
$global:counter = 0
$FolderItems = Get-PnPListItem -List $ListName -PageSize 5000 -Fields FileLeafRef -ScriptBlock { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete `
            ($global:Counter / ($List.ItemCount) * 100) -Activity "Getting Items from List:" -Status "Processing Items $global:Counter to $($List.ItemCount)";}  #| Where {$_.FileSystemObjectType -eq "Folder"}
Write-Progress -Activity "Completed Retrieving Folders from List $ListName" -Completed
 
$FolderStats = @()
#Get Files and Subfolders count on each folder in the library
ForEach($FolderItem in $FolderItems)
{
    #Get Files and Folders of the Folder
    Get-PnPProperty -ClientObject $FolderItem.Folder -Property Files, Folders
     
    #Collect data
    $Data = [PSCustomObject][ordered]@{
        FolderName     = $FolderItem.FieldValues.FileLeafRef
        URL            = $FolderItem.FieldValues.FileRef
        FilesCount     = $FolderItem.Folder.Files.Count
        SubFolderCount = $FolderItem.Folder.Folders.Count
    }
    $Data
    #$FolderStats+= $Data
}
#Export the data to CSV
$FolderStats | Export-Csv -Path $CSVFile -NoTypeInformation