$User = Read-Host "User Email Address:"
$Password = Read-Host "Enter New Password"

Set-Msoluserpassword -UserPrincipalName $User -NewPassword $Password -ForceChangePassword $False 