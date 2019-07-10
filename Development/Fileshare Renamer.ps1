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
    
    if($Complist.SideIndicator -eq "<="){
        #Exists in AD but the fileshare is wrong
        #Assign to variable to pass used for the renaming
        #$ADuserRem = 
        Get-Aduser -Filter * | Where-Object{$_.SamAccountName -Like "$UNConvert*"}
    }elseif{
        
        
    }

}


#ForEach User fomr Drivelist, Check AD to see if there are similarities in the Username
<# Foreach($UDRL in $UDriveList){

    Compare-Object -ReferenceObject $UDRL.Name -DifferenceObject $Users.SamAccountName 
} #>