import-module ActiveDirectory

#readd _Archive after testing
$UDList = Get-childitem -Path "\\usnjfs001\H$" -exclude Batch,Kioware$,rcurran,jbilotti,rraia,vmarzarella #Readd _Archive
$ADuserlist = Get-aduser -SearchBase "OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com" -Filter *


$i = 0

#establish parameters for cimsession
$Computername = 'usnjfs001'
$fullaccess = 'everyone'
$Session = New-CimSession -Computername $Computername

FoReach ($UDL in $UDList){

    $i++

    Write-host "Creating Test folder $($UDL.Name) in _Archive\Test" -ForegroundColor green
    New-Item -Path "\\usnjfs001\H$\_Archive\test\" -ItemType "Directory" -Name $Udl.name 
    
    Write-Progress -Activity "Getting NTFS Permissions" -Status "Processing: $i of $($UDList.Count)"
    
    #isolate the original owners name / permissions by removing all bulk additional users
    $Accounts = Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)" | Where-object{$_.Account -notlike "*Admins" `
        -and $_.Account -notlike "S-1*" `
        -and $_.Account -notlike "*pa-*" `
        -and $_.Account -notlike "*Users*" `
        -and $_.Account -notlike "NT Authority*" `
        -and $_.Account -notlike "BUILTIN*" `
        -and $_.Account -notlike "*rcurran" `
        -and $_.Account -notlike "*jbilotti" `
        -and $_.Account -notlike "*CREATOR*" `
        -and $_.IsInherited -ne $True
    }
    
    #Permissions to restore
    $Accounts2 = Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)"
    $Accounts3 = @("Medline-NT\PC_Admin", "Medline-NT\Excelsior Admins","Builtin\Administrators")

    #Remove the prefix of the account name without Medline-NT\
    $AccNR = $Accounts.Account.accountname -replace [Regex]::Escape('Medline-nt\'),"" | Where-object{$_ -ne ""}

    #Add a header and the hidden share $ after the accountname
    $AccountNameReplace = $AccNR | Select-Object @{Name = "AccountName" ; Expression = {$AccNR}}
    $ANRhidden = "$($Accountnamereplace.accountname)" + '$'

    #rename folder to match AD name then share it
    
    if($UDL.Name -eq $ADuserlist.SamAccountName){
    Write-Host "Renaming $($UDL.Fullname) to $($Accountnamereplace.accountname)" -ForegroundColor Yellow
    Rename-Item -Path $UDL.FullName -Newname "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)"
    
    }Elseif()

    Write-Host "Sharing $($Accountnamereplace.accountname) with the name $ANRHidden (Whatif)" -ForegroundColor Yellow
    New-SMBShare -Name $ANRhidden -Path "H:\_Archive\test\$($AccountNameReplace.AccountName)" -Fullaccess $fullaccess -Cimsession $Session -WhatIf


    ForEach($Acc2 in $Accounts2){

        #Add the accounts from the old folder
        Foreach($AccessRights in $Accs2.Accessrights){

            Write-host "Adding $AccessRights for $Acc2 to $($Accountnamereplace.Accountname)" -ForegroundColor Green            

        }

        #For Test System
        Add-NTFAccess -Path "\\USNJFS001\H$\_Archive\Test\$($AccountNameReplace.Accountname)" -Account $Acc2.Account -AccessRights $Acc2.AccessRights

        #For Live system
        #Add-NTFSACCESS -Path "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)" -Account $Acc2.Account -AccessRights $Acc2.AccessRights
        
    }
}

Remove-Cimsession -cimsession $Session