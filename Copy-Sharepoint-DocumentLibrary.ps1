#Function to Copy library to Another site
Function Copy-PnPLibrary
{
    param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$SourceSiteURL,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$DestinationSiteURL,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$SourceLibraryName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$DestinationLibraryName
    )
   
    Try {
    #Connect to the Source Site
    $SourceConn = Connect-PnPOnline -URL $SourceSiteURL -Interactive -ReturnConnection
    $SourceCtx = $SourceConn.Context
   
    #Get the Source library
    $SourceLibrary =  Get-PnPList -Identity $SourceLibraryName -Includes RootFolder -Connection $SourceConn
   
    #Get the List Template
    $SourceRootWeb = $SourceCtx.Site.RootWeb
    $SourceListTemplates = $SourceCtx.Site.GetCustomListTemplates($SourceRootWeb)
    $SourceCtx.Load($SourceRootWeb)
    $SourceCtx.Load($SourceListTemplates)
    $SourceCtx.ExecuteQuery()
    $SourceListTemplate = $SourceListTemplates | Where {$_.Name -eq $SourceLibrary.id.Guid}
    $SourceListTemplateURL = $SourceRootWeb.ServerRelativeUrl+"/_catalogs/lt/"+$SourceLibrary.id.Guid+".stp"
   
    #Remove the List template if exists    
    If($SourceListTemplate)
    {
        #Remove-PnPFile -ServerRelativeUrl $SourceListTemplateURL -Recycle -Force -Connection $SourceConn
        $SourceListTemplate = Get-PnPFile -Url $SourceListTemplateURL -Connection $SourceConn
        $SourceListTemplate.DeleteObject()
        $SourceCtx.ExecuteQuery()
    }
    Write-host "Creating List Template from Source Library..." -f Yellow -NoNewline
    $SourceLibrary.SaveAsTemplate($SourceLibrary.id.Guid, $SourceLibrary.id.Guid, [string]::Empty, $False)
    $SourceCtx.ExecuteQuery()
    Write-host "Done!" -f Green
   
    #Reload List Templates to Get Newly created List Template
    $SourceListTemplates = $SourceCtx.Site.GetCustomListTemplates($SourceRootWeb)
    $SourceCtx.Load($SourceListTemplates)
    $SourceCtx.ExecuteQuery()
    $SourceListTemplate = $SourceListTemplates | Where {$_.Name -eq $SourceLibrary.id.Guid}     
   
    #Connect to the Destination Site
    $DestinationConn = Connect-PnPOnline -URL $DestinationSiteURL -Interactive -ReturnConnection
    $DestinationCtx = $DestinationConn.Context
    $DestinationRootWeb = $DestinationCtx.Site.RootWeb
    $DestinationListTemplates = $DestinationCtx.Site.GetCustomListTemplates($DestinationRootWeb)
    $DestinationCtx.Load($DestinationRootWeb)
    $DestinationCtx.Load($DestinationListTemplates)
    $DestinationCtx.ExecuteQuery()    
    $DestinationListTemplate = $DestinationListTemplates | Where {$_.Name -eq $SourceLibrary.id.Guid}
    $DestinationListTemplateURL = $DestinationRootWeb.ServerRelativeUrl+"/_catalogs/lt/"+$SourceLibrary.id.Guid+".stp"
   
    #Remove the List template if exists    
    If($DestinationListTemplate)
    {
        #Remove-PnPFile -ServerRelativeUrl $DestinationListTemplateURL -Recycle -Force -Connection $DestinationConn
        $DestinationListTemplate = Get-PnPFile -Url $DestinationListTemplateURL -Connection $DestinationConn
        $DestinationListTemplate.DeleteObject()
        $DestinationCtx.ExecuteQuery()        
    }
   
    #Copy List Template from source to the destination site
    Write-host "Copying List Template from Source to Destination Site..." -f Yellow -NoNewline
    Copy-PnPFile -SourceUrl $SourceListTemplateURL -TargetUrl ($DestinationRootWeb.ServerRelativeUrl+"/_catalogs/lt") -Force -OverwriteIfAlreadyExists -Connection $SourceConn
    Write-host "Done!" -f Green
   
    #Reload List Templates to Get Newly created List Template
    $DestinationListTemplates = $DestinationCtx.Site.GetCustomListTemplates($DestinationRootWeb)
    $DestinationCtx.Load($DestinationListTemplates)
    $DestinationCtx.ExecuteQuery()
    $DestinationListTemplate = $DestinationListTemplates | Where {$_.Name -eq $SourceLibrary.id.Guid}
   
    #Create the destination library from the list template
    Write-host "Creating New Library in the Destination Site..." -f Yellow -NoNewline
    If(!(Get-PnPList -Identity $DestinationLibraryName -Connection $DestinationConn))
    {
        #Create the destination library
        $ListCreation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        $ListCreation.Title = $DestinationLibraryName
        $ListCreation.ListTemplate = $DestinationListTemplate
        $DestinationList = $DestinationCtx.Web.Lists.Add($ListCreation)
        $DestinationCtx.ExecuteQuery()
        Write-host "Library '$DestinationLibraryName' created successfully!" -f Green
    }
    Else
    {
        Write-host "Library '$DestinationLibraryName' already exists!" -f Yellow
    }
  
    Write-host "Copying Files and Folders from the Source to Destination Site..." -f Yellow    
    $DestinationLibrary = Get-PnPList $DestinationLibraryName -Includes RootFolder -Connection $DestinationConn
    #Copy All Content from Source Library's Root Folder to the Destination Library
    If($SourceLibrary.ItemCount -gt 0)
    {
        #Get All Items from the Root Folder of the Library
        $global:counter = 0
        $ListItems = Get-PnPListItem -List $SourceLibraryName -Connection $SourceConn -PageSize 500 -Fields ID -ScriptBlock {Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete `
            (($global:Counter / $SourceLibrary.ItemCount) * 100) -Activity "Getting Items from List" -Status "Getting Items $global:Counter of $($SourceLibrary.ItemCount)"}
       $RootFolderItems = $ListItems | Where { ($_.FieldValues.FileRef.Substring(0,$_.FieldValues.FileRef.LastIndexOf($_.FieldValues.FileLeafRef)-1)) -eq $SourceLibrary.RootFolder.ServerRelativeUrl}
        Write-Progress -Activity "Completed Getting Items from Library $($SourceLibrary.Title)" -Completed
          
        #Copy Items to the Destination
        $RootFolderItems | ForEach-Object {
            $DestinationURL = $DestinationLibrary.RootFolder.ServerRelativeUrl
            Copy-PnPFile -SourceUrl $_.FieldValues.FileRef -TargetUrl $DestinationLibrary.RootFolder.ServerRelativeUrl -Force -OverwriteIfAlreadyExists -Connection $SourceConn
            Write-host "`tCopied $($_.FileSystemObjectType) '$($_.FieldValues.FileRef)' Successfully!" -f Green     
        }
    }
    
    #Cleanup List Templates in source and destination sites
    $SourceListTemplate = Get-PnPFile -Url $SourceListTemplateURL -Connection $SourceConn
    $DestinationListTemplate = Get-PnPFile -Url $DestinationListTemplateURL -Connection $DestinationConn
    $SourceListTemplate.DeleteObject()
    $DestinationListTemplate.DeleteObject()
    $SourceCtx.ExecuteQuery()
    $DestinationCtx.ExecuteQuery()
    #Remove-PnPFile -ServerRelativeUrl $SourceListTemplateURL -Recycle -Force -Connection $SourceConn
    #Remove-PnPFile -ServerRelativeUrl $DestinationListTemplateURL -Recycle -Force -Connection $DestinationConn
    }
    Catch {
        write-host -f Red "Error:" $_.Exception.Message
    }
}
   
#Parameters
$SourceSiteURL = "https://tcco.sharepoint.com/sites/NJ-PrincetonUniversityJobs"
$DestinationSiteURL = "https://tcco.sharepoint.com/sites/NJPrinceton"
$SourceLibraryName = "Shared Documents/General"
$DestinationLibraryName = "Archive"
   
#Call the function to copy document library to another site
Copy-PnPLibrary -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL -SourceLibraryName $SourceLibraryName -DestinationLibraryName $DestinationLibraryName