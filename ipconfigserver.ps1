$Server = Import-csv C:\csv\Srv.csv

ForEach ($Srvs in $server){

    Psexec64.exe \\$($Srvs.hostnames) powershell.exe /c ipconfig /all
    pause
    
}