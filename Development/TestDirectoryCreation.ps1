$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$

#Establish count variable
$i = 0

#establish parameters for cimsession
$Computername = 'usnjfs001'
$fullaccess = 'everyone'
$Session = New-CimSession -Computername $Computername

ForEach($UDL in $Udrivelist){

    $ACL = Get-NTFSaccess -Path "\\USNJFS001\H$\$($UDL.name)" 

    New-Item -Path "\\usnjfs001\H$\_Archive\Test\$($UDL.Name)" -ItemType Directory
    
    ForEach($ACLUser in $ACL){
        #ACLUser.Access and ACLUser.PSChildname
        Write-host "Adding $($ACLUser.AccessRights) for $ACLUser to "
        $ACLUser
        #Set-Acl "C:\Testing\$($UDL.Name)" -AclObject $ACL


    }
    
}


<# $udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$


ForEach($UDL in $Udrivelist){
    $NTFS = Get-NTFSAccess -Path "\\USNJFS001\H$\$($UDL.name)"
    
    New-Item -Path "C:\Testing\$($UDL.Name)" -ItemType Directory

    ForEach($NTFSPerm in $NTFS){
        "Trying to add $($NTFSPerm.Account.Accountname) to $($UDL.name)"
        Add-NTFSACCESS -Path "C:\Testing\$($UDL.Name)" -AccessRights $NTFS.AccessRights -Account $NTFSPerm.Account.AccountName
        
        
    }

} #>