$Comp = Import-csv 'C:\CSV\Bomgar Export.csv'

ForEach ($Computer in $Comp) {

C:\Powershell\ram.ps1 -Computername $Computer.Name | Export-csv C:\CSV\BomgarRam.csv

}