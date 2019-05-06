$Node = Import-csv C:\CSV\Test.csv

ForEach ($Nodes in $Node) {

    Get-CimInstance -Classname Win32_Bios -ComputerName $Nodes | FL SerialNumber
    
}