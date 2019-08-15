$UDTest = Get-item  -Path "\\usnjfs001\H$\_Archive\wmurray" -exclude _archive,Batch,Kioware$,rcurran,jbilotti,rraia,vmarzarella

FoReach ($UDL in $UDTest){

    #isolate the original owners name / permissions
    $Accounts = Get-Ntfsaccess -Path "\\usnjfs001\h$\_Archive\$($udl.name)" | Where{$_.Account -notlike "*Admins" -and $_.Account -notlike "S-1*" `
    -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
    -and $_.IsInherited -ne $True -and $_.Account -notlike "*rcurran" -and $_.Account -notlike "*jbilotti" -and $_.Account -notlike "*CREATOR*"}
    
    #Permissions to restore
    $Accounts2 = Get-Ntfsaccess -Path "\\usnjfs001\h$\_Archive\$($udl.name)"

    #Turn make the account name without Medline-NT\
    $AccNR = $Accounts.Account.accountname -replace [Regex]::Escape('Medline-nt\'),"" | Where{$_ -ne ""}

    #Add a header
    $AccountNameReplace = $AccNR | Select-Object @{Name = "AccountName" ; Expression = {$AccNR}}
    
    #Bring the two together
    $Splat1 = @{
        Accountname = "$($AccountNameReplace.AccountName)"
        Folder = "$($UDL.Name)"

    }

    Rename-Item -Path $UDL.FullName -Newname "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)"
    
}