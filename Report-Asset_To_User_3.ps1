$Node = Import-csv C:\CSV\Test.csv

$Collection = ForEach ($nodes in $node) {

Write-host "Attempting to lookup" $Nodes.Hostname

    try {
        $UName = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem -ErrorAction Stop | Select-Object UserName
        $HN = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_ComputerSystem -ErrorAction Stop | Select-Object PSComputerName
        $OS = Get-Wmiobject -Computername $Nodes.Hostname -Class Win32_OperatingSystem -ErrorAction Stop | Select-Object Caption

        $properties = @{
            "UserName" = $($UName.Username)
            "Hostname" = $($HN.PSComputerName)
            "OS" = $($OS.Caption)
            "NotFound" = $null
        }

        New-Object -Typename PSCustomObject -Property $properties
    }

		Catch [System.Exception] {
        #$RH = $Nodes
        $Nodes
		#$RH = $($RH.Hostname) #-replace ‘[@{}]’
		Add-Content -Path 'C:\CSV\AppLog.log' -Value "failed to lookup $($Nodes.Hostname)"

	}

    catch {
        $properties = @{
            "Username" = $null
            "Hostname" = $null
            "OS" = $null
            "NotFound" = $($nodes.Hostname)

        }



        New-Object -TypeName PSObject -Property $properties

    }

}

$collection | Export-csv C:\CSV\UserInfo$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv -NoTypeInformation -Append