$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$


ForEach($UDL in $Udrivelist){
    $NTFS = Get-NTFSAccess -Path "\\USNJFS001\H$\$($UDL.name)"
    
    New-Item -Path "C:\Testing\$($UDL.Name)" -ItemType Directory

    ForEach($NTFSPerm in $NTFS){

        Add-NTFSACCESS -Path "C:\Testing\$($UDL.Name)" -AccessRights FullControl 

        remove-ntfs
    }

}