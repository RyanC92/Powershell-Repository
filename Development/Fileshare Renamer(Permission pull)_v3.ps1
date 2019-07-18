#Fileshare Renamer(Permission pull)_v3
#Ryan Curran

import-module ActiveDirectory

$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$

ForEach($udl in $udrivelist){

    Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)" | Where{$_.Account -notlike "*Domain Admins" -and $_.Account -notlike "S-1*" `
    -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
    -and $_.IsInherited -ne $True}

    #Get-Ntfsaccess -path "\\usnjfs001\h$\$($udl.name)" | Where{$_.Account -notlike ''}

}