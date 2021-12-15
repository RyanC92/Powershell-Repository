$Computers = Import-csv C:\Temp\STLookup.csv

Foreach($Computer in $Computers){

    Get-ADcomputer -filter 'Description -like "*$($Computer.servicetags)*"' -properties Description | Select Name, Description
}