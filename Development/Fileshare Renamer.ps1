<#Pull List of AD users
Match them to similarities in the other users names
Rename the folder and reshare

By: Ryan Curran
7/10/19
#>

import-module activedirectory

$UDriveList = Get-Childitem -Path "\\usnjfs001\H$" -exclude _Archive,Batch,Kioware$
$Users = Get-aduser -Filter {Enabled -eq $True} -SearchBase "OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com" 
$Splat1 = @{
    UserName = $Users.SamAccountName
    Folder = $UDriveList.Name
}

$Comp = Compare-Object -ReferenceObject $Splat1.Folder -DifferenceObject $Splat1.Username

ForEach($CompList in $Comp){
    $UNConvert = $Complist.InputObject
    $FNConvert = $Complist.
    #if the side indicator states that the Folder name exists on the fileshare but not in AD, (User may not exist at all or it may be incorrect)
    if($Complist.SideIndicator -eq "<="){
        #Search AD for a username that is SIMILAR to the fileshare name 
        $ADuserRem = Get-Aduser -Filter {Enabled -eq $True} -SearchBase "OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com" | Where-Object{$_.SamAccountName -Like "$UNConvert*"}
        #If exists, Pass username to variable to use for RENAMING the folder

        #After Folder is renamed, RESHARE as Username$, assign permissions to that user for full control
    }elseif($CompList.SideIndicator -eq "=>"){
        #These need to be renamed to match AD
        Write-host "$($Complist.InputObject) - Exists in AD" -ForegroundColor Red

    }

}


#ForEach User fomr Drivelist, Check AD to see if there are similarities in the Username
<# Foreach($UDRL in $UDriveList){

    Compare-Object -ReferenceObject $UDRL.Name -DifferenceObject $Users.SamAccountName 
} #>