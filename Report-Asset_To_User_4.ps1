$Node = Import-csv C:\CSV\Test.csv

$Collection = ForEach ($nodes in $node) {

Write-host "Attempting to lookup" $Nodes.Hostname

    try {
		
		Test-Connection $($Hns.Hostname) -quiet -Count 1 -ErrorAction Stop

        $UName = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object UserName
        $HN = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object PSComputerName
        $OS = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_OperatingSystem | Select-Object Caption
        
        $properties = @{
            "UserName" = $($UName.Username)
            "Hostname" = $($HN.PSComputerName)
            "OS" = $($OS.Caption)
            "NotFound" = $null
        }

        New-Object -Typename PSCustomObject -Property $properties
    }

    catch [System.Exception] {

        Write-host "$($nodes.hostname) has failed"

        $($nodes.hostname) | Export-csv C:\CSV\Error$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv -append -NoTypeInformation
       

    }

}

$collection | Export-csv C:\CSV\UserInfo$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv -NoTypeInformation -Append
