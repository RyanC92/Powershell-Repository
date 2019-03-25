$Members = @()

$Users =  Import-csv "C:\CSV\AplicareEmailSamAccountName.csv" 

$Users | ForEach-Object { Get-Aduser -Identity $_.SamAccountName -Properties memberof}  | Select Name, @{l="Member Of";e={[string]$_.MemberOf}} #| Export-csv C:\CSV\AplicareUsersMemberOf.csv -Notypeinformation
