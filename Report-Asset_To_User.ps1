$Node = Import-csv C:\CSV\Test.csv

ForEach ($nodes in $node) {

Write-host "Attempting to lookup" $Nodes.Hostname

$UName = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object UserName
$HN = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object PSComputerName
$OS = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_OperatingSystem | Select-Object Caption


New-Object -Typename PSCustomObject -Property @{
    UserName = $UName
    Hostname = $HN
    OS = $OS


}   | Export-csv -Path C:\CSV\UserInfo.csv -NoTypeInformation -Append

}