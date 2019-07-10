#Checks AD For a list of Users, takes their SamAccountName, compares with the list of U drives, if a User exists in AD but not the fileshare, create and share the fileshare
#If the fileshare has a folder that AD does not, move the folder to _Archive

#By Ryan Curran
#7/10/19

$Users = Get-aduser -Filter * -SearchBase "OU=Users,OU=US_Excelsior_Medical_Neptune_NJ,OU=Users_And_Computers,DC=medline,DC=com"
$UDriveList = Get-Childitem -Path "\\usnjfs001\H$" -exclude _Archive,Batch,Kioware$

