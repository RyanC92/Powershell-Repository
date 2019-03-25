#Get-ACL for each directory within the USNJFS001 Fileshare
$Filename = 'C:\CSV\usnjfs001-Groups-Permissions.CSV'

$Paths = "G:\*"

$ACL = Get-ACL -Path $Paths 

$ACL | Select PSDrive, PSChildName, PSPath -ExpandProperty Access| export-csv $Filename

Write-Host " Complete" -ForegroundColor green
Write-Host "Your file has been saved to $Filename"