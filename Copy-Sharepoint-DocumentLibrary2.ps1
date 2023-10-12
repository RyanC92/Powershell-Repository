#Config Variables
$SiteURL = "https://tcco.sharepoint.com/sites/NJ-PrincetonUniversityJobs"
$SourceLibraryURL = "Shared Documents/General/Chem Old Files" #Site Relative URL from the current site
$TargetLibraryURL = "/sites/NJPrinceton/Archive/Chem Old Files" #Server Relative URL of the Target Folder
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get all Items from the Document Library
$Items = Get-PnPFolderItem -FolderSiteRelativeUrl $SourceLibraryURL | Where {$_.Name -ne "Forms"}

$Items

#Move All Files and Folders Between Document Libraries
Foreach($Item in $Items)
{
    Move-PnPFile -SourceUrl $Item.ServerRelativeUrl -TargetUrl $TargetLibraryURL -AllowSchemaMismatch -Force -AllowSmallerVersionLimitOnDestination
    Write-host "Moved Item:"$Item.ServerRelativeUrl
}