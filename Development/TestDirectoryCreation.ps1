$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$

ForEach($UDL in $Udrivelist){

    $ACL = Get-Acl -Path "\\USNJFS001\H$\$($UDL.name)" 

    #New-Item -Path "C:\Testing\$($UDL.Name)" -ItemType Directory
    
    ForEach($ACLUser in $ACL){
        #ACLUser.Access and ACLUser.PSChildname
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