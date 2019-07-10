$Users = Get-Childitem -Path "\\USNJFS001\H$" | select Name
#$Users = Import-csv C:\CSV\FileshareRemediation1.csv

ForEach ($User in $users){

    Try{
        Write-host "Adding Domain Admins with Full Control to $($User.Name)" -ForegroundColor Yellow
        Add-ntfsaccess -Path "\\usnjfs001\H$\$($User.name)" -Account "Domain Admins" -AccessRights FullControl -ErrorAction Stop

        Write-Host "Adding Successful" -ForegroundColor Green
        
        "User Rights Are now below:"
        Get-NTFSaccess -Path "\\USNJFS001\H$\$($User.Name)" | Where ($_.Account -like "*Domain*" ) | Select "Account","AccessRights"

    }Catch{
        Write-Host "$($User.name) Failed" -ForegroundColor Red
        $User | Select @{Name = "User Share"; Expression = {$($User.Name)}} | Export-CSV C:\CSV\FailedPermissions.csv -Append -NoTypeInformation

    }
}