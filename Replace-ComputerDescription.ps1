#This script would grab each computer from an OU Searchbase and Replace the symbol or text with what you entered in the description

$OU = Read-Host "Please enter the OU that you want to work on (copy and paste it from AD, Example: OU=Computers,OU=City,OU=Region,OU=Offices,DC=DCName,DC=end" 
Write-host "You Selected OU - $OU" -ForegroundColor yellow -BackgroundColor green
$Computers = Get-adcomputer -filter * -Searchbase "$OU" -properties Description | Select Name, Description
$Symbol1 = Read-Host "Please Enter the text that you want to replace (What already exists in the description)"
$Symbol2 = Read-Host "Please Enter the text that you want to be used as the replacement text"

ForEach ($Comp in $Computers){

    if($Comp.Description -ne $Null){
        "$($Comp.Name): $($Comp.Description)"
        "Setting to: $($Comp.Description.Replace("$Symbol1","$Symbol2"))"
        
        Set-ADComputer -Identity $Comp.name -Description $Comp.Description.Replace("$Symbol1","$Symbol2")
    }

}