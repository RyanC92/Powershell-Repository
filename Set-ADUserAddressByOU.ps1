#This script would grab each user from an OU Searchbase and check the Title against the description, if the Title is different (which is correct)
#It will take the Title and replace the description, this is for BU's that use the Description field as a replacement for Title.
Import-module activedirectory
Write-Host "This script will set the address for all users within the OU you select, please answer the questions below exactly as that will be how it is entered into Active Directory`n"
$OU = Read-Host "Please enter the OU that you want to work on" 
$Address = Read-Host "Please enter the Street Address (Ex: 685 US highway 202/206)"
$Suite = Read-Host "Please enter the Suite Number if applicable"
$City = Read-Host "Please enter the City"
$State = Read-Host "Please enter the 2 Letter State (Ex: NJ)"
$BUName = Read-Host "Please enter your BU name (Ex: New Jersey, Pittsburgh, San Antonio)"
Write-host "You entered - Organizational Unit: $OU
Address: $Address
Suite: $Suite
City: $City
State: $State
Office Name: $BUName" -ForegroundColor yellow -BackgroundColor Darkgreen

$Users = Get-aduser -filter * -Searchbase "$OU" -properties City, l, Office, physicalDeliveryOfficeName, StreetAddress, st, state 

$countChange = 0
$countSame = 0

Foreach ($User in $Users){

    "=======================================
    Updating Address for $($User.Name) to:
    $Address
    $Suite
    $City, $State
    ========================================"

    Set-aduser -Identity "$($User.SamAccountName)" -City $City -l $City -Office $BUName -replace @{phyiscalDeliveryOfficeName = $BUName} -StreetAddress "$Address, $Suite" -state $state
    $countChange++

}

Write-host "===" -ForegroundColor Red
Write-host "Out of a total of $($Users.count) processed employees in $OU
$countChange employee addresses updated" -ForegroundColor Green
Write-Host "===" -ForegroundColor Red