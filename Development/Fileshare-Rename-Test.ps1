$UDTest = Get-item  -Path "\\usnjfs001\H$\_Archive\mkaruzas" -exclude _archive,Batch,Kioware$,rcurran,jbilotti,rraia,vmarzarella

#establish parameters for cimsession
$Computername = 'usnjfs001'
$fullaccess = 'everyone'
$Session = New-CimSession -Computername $Computername

FoReach ($UDL in $UDTest){

    #isolate the original owners name / permissions
    $Accounts = Get-Ntfsaccess -Path "\\usnjfs001\h$\_Archive\$($udl.name)" | Where{$_.Account -notlike "*Admins" -and $_.Account -notlike "S-1*" `
    -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
    -and $_.IsInherited -ne $True -and $_.Account -notlike "*rcurran" -and $_.Account -notlike "*jbilotti" -and $_.Account -notlike "*CREATOR*"}
    
    #Permissions to restore
    $Accounts2 = Get-Ntfsaccess -Path "\\usnjfs001\h$\_Archive\$($udl.name)"
    $Accounts3 = @{"Medline-NT\Domain Admins", "Medline-NT\Excelsior Admins","Builtin\Administrators"}

    #Turn make the account name without Medline-NT\
    $AccNR = $Accounts.Account.accountname -replace [Regex]::Escape('Medline-nt\'),"" | Where{$_ -ne ""}

    #Add a header
    $AccountNameReplace = $AccNR | Select-Object @{Name = "AccountName" ; Expression = {$AccNR}}
    
    #Bring the two together
    $Splat1 = @{
        Accountname = "$($AccountNameReplace.AccountName)"
        Folder = "$($UDL.Name)"

    }

    $ANRhidden = "$($Accountnamereplace.accountname)" + '$'
    Rename-Item -Path $UDL.FullName -Newname "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)"
    
    New-SMBShare -Name $ANRhidden -Path "H:\_Archive\$($AccountNameReplace.AccountName)" -Fullaccess $fullaccess -Cimsession $Session 

    ForEach($Acc2 in $Accounts2){
        
        "Adding $($Acc2.AccessRights) to $($Accountnamereplace.Accountname)"
        Add-NTFSACCESS -Path "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)" -Account $Acc2.Account -AccessRights $Acc2.AccessRights
        
            ForEach($Acc3 in $Accounts3){

                Add-NTFSaccess -Path "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)" -Account $Acc3 -AccessRights "FullControl"
            }
        

    }
}

Remove-Cimsession -cimsession $Session