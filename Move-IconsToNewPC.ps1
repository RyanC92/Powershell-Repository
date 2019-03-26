
$NewPC = Read-Host "Enter the new PC HOSTNAME(Ex: NEP12345)"
$User = Read-Host "Enter the users login name (Ex: Jsmith12345)"
$PAUser = Read-Host "Enter your PA username"
$Cred = Get-Credential -Username "Medline-nt\$PaUser" -Message "Fill out PA Credentials"

New-PSDrive -Name H -PSProvider FileSystem -Root "\\$newPC\c$" -Credential $Cred
Write-Host "Drive Mounted "
Copy-Item "C:\Users\$User\Desktop\*" "H:\Users\$User\Desktop\" -Recurse
Write-Host "Items copied"
Remove-PSDrive -Name H
Write-Host "Drive Removed"
Write-Host "Move Complete"
Pause