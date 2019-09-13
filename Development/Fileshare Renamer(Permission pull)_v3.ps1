#Fileshare Renamer(Permission pull)_v3
#Ryan Curran

import-module ActiveDirectory

#$udrivelist = Get-Childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$,rcurran,jbilotti,rraia,vmarzarella


ForEach($udl in $udrivelist){

    #isolate the original owners name / permissions
    $Accounts = Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)" | Where-object{$_.Account -notlike "*Admins" -and $_.Account -notlike "S-1*" `
    -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
    -and $_.IsInherited -ne $True -and $_.Account -notlike "*rcurran" -and $_.Account -notlike "*jbilotti" -and $_.Account -notlike "*CREATOR*"}
    
    #Permissions to restore
    $Accounts2 = Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)"

    #Turn make the account name without Medline-NT\
    $AccNR = $Accounts.Account.accountname -replace [Regex]::Escape('Medline-nt\'),"" | Where{$_ -ne ""}

    #Add a header
    $AccountNameReplace = $AccNR | Select-Object @{Name = "AccountName" ; Expression = {$AccNR}}

    #Bring the two together
    $Splat1 = @{
        Accountname = "$($AccountNameReplace.AccountName)"
        Folder = "$($UDL.Name)"

    }

    $AccountNameReplace
    #$UDL | Select *


    #Rename-Item 
    
 

    <# Try{

        $ADUSers = Get-ADuser -Identity $AccountNameReplace -ErrorAction Stop
        

    }Catch{

        $UDL | Select Name,@{Name = Username; Expression={$Accountnamereplace} |  Export-csv C:\CSV\UDLFailure.csv -append -NoTypeInformation

    } #>




    #Get-Ntfsaccess -path "\\usnjfs001\h$\$($udl.name)" | Where{$_.Account -notlike ''}

}