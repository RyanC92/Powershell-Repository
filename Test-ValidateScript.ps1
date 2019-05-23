$HN = Import-csv C:\csv\Hosts.csv

    ForEach($HNs in $HN){
     
            $tF = Test-Connection $($Hns.Hostname) -quiet -Count 1 -ErrorAction Stop
            
            if ($tF -eq $True){
                
                #Write code to execute
                $Hns.Hostname

            }else {
                #Export your hostnames that failed the ping
                $Hns.Hostname | Export-csv C:\CSV\Failures.csv -append notypeinformation
            }

    }
