#readd _Archive after testing
$UDList = Get-childitem -Path "\\usnjfs001\H$" -exclude _archive,Batch,Kioware$,rcurran,jbilotti,rraia,vmarzarella

$i = 0

#establish parameters for cimsession
$Computername = 'usnjfs001'
$fullaccess = 'everyone'
$Session = New-CimSession -Computername $Computername

FoReach ($UDL in $UDList){
    
    $i++
    
    Write-Progress -Activity "Getting NTFS Permissions" -Status "Processing: $i of $($UDList.Count)"
    
    #isolate the original owners name / permissions
    $Accounts = Get-Ntfsaccess -Path "\\usnjfs001\h$\$($udl.name)" | Where-object{$_.Account -notlike "*Admins" -and $_.Account -notlike "S-1*" `
        -and $_.Account -notlike "*pa-*" -and $_.Account -notlike "*Users*" -and $_.Account -notlike "NT Authority*" -and $_.Account -notlike "BUILTIN*" `
        -and $_.IsInherited -ne $True -and $_.Account -notlike "*rcurran" -and $_.Account -notlike "*jbilotti" -and $_.Account -notlike "*CREATOR*"}
    
    #Permissions to restore
    $Accounts2 = Get-Ntfsaccess -Path "\\usnjfs001\h$\_Archive\$($udl.name)"
    $Accounts3 = @("Medline-NT\Domain Admins", "Medline-NT\Excelsior Admins","Builtin\Administrators")

    #Turn make the account name without Medline-NT\
    $AccNR = $Accounts.Account.accountname -replace [Regex]::Escape('Medline-nt\'),"" | Where-object{$_ -ne ""}

    #Add a header and the hidden share $ after the accountname
    $AccountNameReplace = $AccNR | Select-Object @{Name = "AccountName" ; Expression = {$AccNR}}
    $ANRhidden = "$($Accountnamereplace.accountname)" + '$'

    #rename folder to match AD name then share it
    "Renaming $($UDL.Fullname) to $($Accountnamereplace.accountname)"
    Rename-Item -Path $UDL.FullName -Newname "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)"
    "Sharing $($Accountnamereplace.accountname) with the name $ANRHidden"
    New-SMBShare -Name $ANRhidden -Path "H:\_Archive\$($AccountNameReplace.AccountName)" -Fullaccess $fullaccess -Cimsession $Session 


    ForEach($Acc2 in $Accounts2){

        #Add the accounts from the old folder
        Write-host "Adding $($Acc2.AccessRights) for $Acc2 to $($Accountnamereplace.Accountname)" -ForegroundColor Green
        Add-NTFSACCESS -Path "$($UDL.Root)\$($UDL.Parent)\$($AccountNameReplace.AccountName)" -Account $Acc2.Account -AccessRights $Acc2.AccessRights
        
    }
}

Remove-Cimsession -cimsession $Session