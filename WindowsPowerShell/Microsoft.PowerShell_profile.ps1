import-module activedirectory

Function Connect-ExOnline{

$Credential = Get-Credential -Credential Rcurran@excelsiormedical.com

Write-Output "Getting Exchange Online cmdlets"

$session = New-PSSession -ConnectionUri https://ps.outlook.com/Powershell `
    -ConfigurationName Microsoft.Exchange -Credential $Credential `
    -Authentication Basic -AllowRedirection
Import-PSSession $session

Connect-MsolService -Credential $Credential

}

Function PWchange{

$User = Read-Host "User Email Address:"
$Password = Read-Host "Enter New Password"

Set-Msoluserpassword -UserPrincipalName $User -NewPassword $Password -ForceChangePassword $False 

}
