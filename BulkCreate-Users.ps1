#Create users in bulk with a CSV File for Office 365

$Path = Read-Host "Please copy the path of the CSV file for the user accounts"

Import-CSV -Path "$Path" | ForEach-Object { New-Msoluser -UserPrincipalName $_.Email -FirstName $_.First -LastName $_.Last -DisplayName $_.DisplayName -Title $_.Title -Office $_.Office -PhoneNumber $_.Office_Phone -StreetAddress $_.Street_Address -City $_.City -State $_.State -PostalCode $_.Zip -Password <password> }