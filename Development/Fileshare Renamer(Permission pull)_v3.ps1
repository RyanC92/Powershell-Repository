#Fileshare Renamer(Permission pull)_v3
#Ryan Curran

import-module ActiveDirectory

$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$

ForEach($udl in $udrivelist){

    <# Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)" | Where{$_.Account -notlike "*Domain Admins" -and $_.Account -notlike "S-1*" `
    -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
    -and $_.IsInherited -ne $True}
 #>
    $Accounts = Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)" | Where{$_.Account -notlike "*Admins" -and $_.Account -notlike "S-1*" `
    -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
    -and $_.IsInherited -ne $True -and $_.Account -notlike "*rcurran" -and $_.Account -notlike "*jbilotti"}
    
    $AccountName = $Accounts.Account | Select AccountName #| Where{$_.Accountname -notlike "*jbilotti" -and $_.Accountname -notlike "*rcurran"}
    #$Accountname
    $AccountNameReplace = $Accountname.AccountName -replace [Regex]::Escape('Medline-nt\'),"" | Where{$_ -ne ""}
    $udl
    $Accountnamereplace
    #$Accountnamereplace

    <# Try{

        $ADUSers = Get-ADuser -Identity $AccountNameReplace -ErrorAction Stop
        

    }Catch{

        $UDL | Select Name,@{Name = Username; Expression={$Accountnamereplace} |  Export-csv C:\CSV\UDLFailure.csv -append -NoTypeInformation

    } #>




    #Get-Ntfsaccess -path "\\usnjfs001\h$\$($udl.name)" | Where{$_.Account -notlike ''}

}