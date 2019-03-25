#This Report is not working

$Users=Import-Csv C:\csv\vm2.csv

$logfile = "C:\csv\emailscriptlog-$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv"

$csv = @()


ForEach($user in $users){

$adInfo = Get-ADUser -Filter "Userprincipalname -eq '$($user.userprincipalname)'" -properties *

$props = @{

"Name"=$adInfo.Name

"Title"=$adInfo.Title

"Manager" = [regex]::Match($adInfo.Manager,"CN=(\w+),.*").Captures.groups[1].value

"Department"=$adInfo.Department

}

$obj = New-Object -TypeName psobject -Property $props

$csv += $obj

}

$csv | Export-Csv -Path $logfile -Force -Append -NoTypeInformation