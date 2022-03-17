#Prompt user for group name
Write-Host "Enter a security group " -ForegroundColor Red -NoNewLine
$GroupName = Read-Host
Write-host "$GroupName has been selected" -ForegroundColor Green -BackgroundColor Black


Get-ADGroupMember -Identity $GroupName -Recursive |
Get-ADUser -Properties physicaldeliveryofficename |
Select Name,ObjectClass,SamAccountName,physicaldeliveryofficename |
Sort-Object Name |
Export-Excel "c:\temp\$($GroupName)_$([DateTime]::Now.ToSTring("MM-dd-yyyy hhmm tt")).xlsx" -TableStyle Light1 -AutoSize -Append