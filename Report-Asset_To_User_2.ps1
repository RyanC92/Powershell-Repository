$Node = Import-csv C:\CSV\Test.csv

$Collection = ForEach ($nodes in $node) {

Write-host "Attempting to lookup" $Nodes.Hostname

    try {
        $UName = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object UserName
        $HN = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object PSComputerName
        $OS = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_OperatingSystem | Select-Object Caption

        $properties = @{
            UserName = $UName
            Hostname = $HN
            OS = $OS
            NotFound = $null
        }

        New-Object -Typename PSCustomObject -Property $properties
    }

    catch {
        $properties = @{
            Username = $null
            Hostname = $null
            OS = $null
            NotFound = $nodes

        }

        New-Object -TypeName PSObject -Property $properties

    }

}

$collection | Export-csv C:\CSV\UserInfo.csv -NoTypeInformation -Append
