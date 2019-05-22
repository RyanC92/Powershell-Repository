$HN = Import-csv C:\csv\Hosts.csv

    ForEach($HNs in $HN){

        [ValidateScript({Test-Connection -ComputerName $($HNs.Hostname) -Quiet -Count 1})]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $Env:COMPUTERNAME
        

        <#ForEach ($Comp in $ComputerName){
            
            {
                $output = @{ 'ComputerName' = $comp }
                $output.UserName = (Get-WmiObject -Class win32_computersystem -ComputerName $comp).UserName
                [PSCustomObject]$output
            }

        }#>

    }
