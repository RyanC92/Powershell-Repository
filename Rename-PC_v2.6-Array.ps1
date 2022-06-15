$iprange = @(2..253)

$cred = Get-Credential

foreach($ip in $iprange){

    $IPaddr = "172.22.47.$ip"
    $Online = Test-Connection -IPAddress $IPAddr -Quiet -count 1
    $online

    if($online -eq $True){
        Write-host "Querying: $IPaddr" -ForegroundColor Green

        try{
            $HN = Get-wmiobject -ComputerName $IPAddr -Class Win32_ComputerSystem | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue
            Write-host "Name is: $HN" -ForegroundColor Green
            if($HN -like "SOMLAP*"){
                "Renaming $HN"
                $HN = $HN.Replace("SOM","NJO")
                "To $HN"
                Rename-computer -Computername $IPAddr -NewName "$HN" -DomainCredential $Cred
            }else{

            }
        }catch{

        }
    }
}