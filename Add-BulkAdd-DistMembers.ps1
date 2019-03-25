do {

$DistGroup = Read-Host "Please Enter the DisplayName of the Distribution Group"
$CSVPath = Read-Host "Please Paste the full path to the CSV file (Including the file itself)"

Import-CSV -Path "$CSVPath" | ForEach-Object { Add-DistributionGroupMember -Identity "$DistGroup" -Member $_.members}

Get-DistributionGroupMember -Identity "$Distgroup"

$response = Read-Host "Again? (Y/N):"

}

while ($response -eq "y")