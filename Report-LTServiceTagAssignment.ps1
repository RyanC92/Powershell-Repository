$Computers = Import-csv C:\Temp\STLookup.csv

Foreach($Computer in $Computers){

    Get-ADcomputer -filter * -properties Description | Select Name, Description | where {$_.Description -like "*$($Computer.ServiceTags)*"}
}