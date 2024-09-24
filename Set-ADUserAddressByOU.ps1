#This Script will update the address based on the user captured data for the OU that is selected.

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

$Users = Get-aduser -filter * -Searchbase "$OU" -properties City, l, Office, PhysicalDeliveryOfficeName, StreetAddress, st, state 

$countChange = 0

Foreach ($User in $Users){

    "=======================================
    Updating Address for $($User.Name) to:
    $Address
    $Suite
    $City, $State
    ========================================"


    Set-ADUser -Identity "$($User.SamAccountName)" -City $City -Office $BUName -StreetAddress "$Address, $Suite" -State $State -l $null

    $countChange++

}

Write-host "===" -ForegroundColor Red
Write-host "Out of a total of $($Users.count) processed employees in $OU
$countChange employee addresses updated" -ForegroundColor Green
Write-Host "===" -ForegroundColor Red