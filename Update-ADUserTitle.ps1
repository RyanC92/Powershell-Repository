#This script would grab each user from an OU Searchbase and check the Title against the description, if the Title is different (which is correct)
#It will take the Title and replace the description, this is for BU's that use the Description field as a replacement for Title.
$OU = Read-Host "Please enter the OU that you want to work on" 
Write-host "You Selected OU - $OU" -ForegroundColor Green -BackgroundColor Yellow
$Users = Get-aduser -Searchbase "$OU" -properties Title, Description | Select Name, Userprincipalname, Description, Title

Foreach ($User in $Users){
    Read-host ""
    Set-aduser -identity "$($User.Userprincipalname)" -Title "$($User.Title)"
    
}