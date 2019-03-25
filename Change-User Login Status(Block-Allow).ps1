#Get user input
$User = Read-Host "User(Email)"
$Status = Read-Host "Set Status (True (Blocked) or False (Not Blocked))" #True will block access, False will allow access

#IF statement for true or false.
IF($Status -eq "True"){

Set-Msoluser -UserPrincipalName $User -BlockCredential $True

}

#If not true, and if $Status is equal to False then proceed.
ElseIf($Status -eq "False"){

Set-MsolUser -UserPrincipalName $User -BlockCredential $False

}



