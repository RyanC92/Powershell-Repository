
do {

$User = Read-Host "User Email Address:"

Remove-Msoluser -UserPrincipalName $user -force

$response = Read-Host "Repeat? (Y/N):"
}

while ($response -eq "y")