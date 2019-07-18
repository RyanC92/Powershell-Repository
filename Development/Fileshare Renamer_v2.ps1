<#Pull List of AD users
Match them to similarities in the other users names
Rename the folder and reshare

By: Ryan Curran
7/10/19
#>

Import-module activedirectory

$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$
$Users = Get-ADuser -Filter {Enabled -eq $True} -Searchbase "OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=COM"
$Splat1 = @{
    Username = $Users.SamAccountName
    Folder = $UDriveList.Name
}

$Comp = Compare-Object -ReferenceObject $Splat1.Folder -DifferenceObject $Splat1.Username

ForEach ($Complist in $Comp) {

    $UNConvert = $Complist.inputobject
    $FNConvert = $Complist.SideIndicator

    #if the side indicator states that the Folder name exists on the fileshare but not in AD, (User may not exist at all or it may be incorrect)

    if ($Complist.SideIndicator -eq "<=" ) {
        #Search AD for a username that is SIMILAR to the fileshare name 

        $ADuserRem = $Users | Where-Object {$_.SamAccountName -Like "$UNConvert*"}
        #If exists, Pass username to variable to use for RENAMING the folder
<#         "User: $($AduserRem.SamAccountname)"
        "Folder: $($UNConvert)" #>
        $ADuserMeasure = $ADuserRem | Measure

        if($Adusermeasure.count -ne '1'){
            $UNConvert
            $Adusermeasure
        }
       # Write-Host "$UNConvert is the Foldername"
       # Write-Host "$($ADuserRem.SamAccountName) is the correct username"

        #After Folder is renamed, RESHARE as Username$, assign permissions to that user for full control

    } <#ElseIf ($Complist.SideIndicator -eq "=>"){
        #These need to be renamed to match AD
        Write-host "$($Complist.InputObject) - Exists in AD" -ForegroundColor Red

    #>
    Else{

    }
} 
