$PCS = Import-csv C:\Temp\PCList.csv

ForEach($PC in $PCS){

    $SGDVer = Get-wmiobject -query "SELECT * FROM Win32_Product Where Name Like '%Secure Global Desktop Client%'" -ComputerName $PC.IPAddress
    $SGDVer | Select @{Name= "IPAddress"; Expression = {$($PC.IpAddress)}}, Name, Vendor, Version | Export-CSV C:\Temp\SGDOutput.csv -notypeinformation
    
}