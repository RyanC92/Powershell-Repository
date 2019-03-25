#Test
$Users = Import-CSV C:\CSV\TEst_mac.csv 

ForEach($SamAccountName in $Users)

{

Get-Aduser $SamAccountName | Set-AdAccountPassword -Newpassword $pass -reset

Get-ADuser $SamAccountName | Set-Aduser -ChangePasswordatLogon $False -PasswordNeverExpires $True

Write-Host "Password has beensreset for the user: $user"

}