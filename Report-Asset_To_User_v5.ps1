$Node = Import-csv C:\CSV\Test.csv

$Collection = ForEach ($nodes in $node) {

Write-host "Attempting to lookup" $Nodes.Hostname

    try {

        $pt = Test-Connection $($Nodes.Hostname) -Quiet -Count 1 

        if ($pt -eq $false) {error}

        $UName = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object UserName
        $HN = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem | Select-Object PSComputerName
        $OS = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_OperatingSystem | Select-Object Caption

        $properties = @{
            "UserName" = $($UName.Username)
            "Hostname" = $($HN.PSComputerName)
            "OS" = $($OS.Caption)

        }

        New-Object -Typename PSCustomObject -Property $properties
    }

		Catch [System.Management.Automation.CommandNotFoundException] {

        Write-host "$($nodes.hostname) has failed"
        "$open"

        $($nodes.Hostname) | Add-Content C:\CSV\Error.log
	}
}

$collection | Export-csv C:\CSV\UserInfo$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv -NoTypeInformation -Append

Get-Content C:\CSV\Error.log | Add-Content C:\CSV\Error$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv 

Remove-Item C:\CSV\Error.log
