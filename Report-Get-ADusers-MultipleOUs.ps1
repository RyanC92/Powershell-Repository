#####################################
##         Ryan Curran             ##
##           8/23/17               ##
##Collect Users from Multiple OU's ##
#####################################

Import-Module ActiveDirectory

Set-location AD:

'OU=Users,OU=HQ,DC=Excelsior,DC=Local','OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=Excelsior, DC=Local' `
| ForEach-Object { Get-Aduser -Filter * -SearchBase $_ -Properties GivenName,EmailAddress,SamAccountName,Name } `
| where { $_.Enabled -eq $True} | Export-CSV C:\CSV\MultipleOUExport-Excelsior.csv -NoTypeInformation
