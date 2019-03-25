Import-MOdule ActiveDirectory
$location = Get-location

if ($location -ne "AD:\OU=TMS Users,OU=HQ,DC=excelsior,DC=local" ) {
    Set-Location AD:
    Set-location "OU=TMS Users,OU=HQ,DC=excelsior,DC=local" 
    Get-Aduser -Filter * | ForEach{ Set-Aduser $_.SamAccountName -ChangePasswordAtLogon $False }
    
    }
else {
    Get-Aduser -Filter * | ForEach{ Set-Aduser $_.SamAccountName -ChangePasswordAtLogon $False }

    }
