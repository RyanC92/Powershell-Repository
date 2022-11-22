$iprange = @(2..253)

$cred = Get-Credential
$NJOLTS = get-adcomputer -filter {(Name -like "NJOLAP*") -and (Enabled -eq $True)}

$i = 1

foreach($ip in $iprange){
    '-------------'
    "Processing: $i"
    $IPaddr = "172.18.47.$ip"
    $Online = Test-Connection -IPAddress $IPAddr -Quiet -count 1
    "Testing Result: Online is $online"

    if($online -eq $True){

        Write-host "Querying: $IPaddr" -ForegroundColor Green

        try{

            $HN = Get-wmiobject -ComputerName $IPAddr -Class Win32_ComputerSystem | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue
            
            Write-host "Response Received `nName is: $HN" -ForegroundColor DarkGreen
            "Gathered remote hostname"

            if($HN -like "SOMLAP*"){
                
                $HN2 = $HN.Replace("SOM","NJO")
                "Checking $HN to avoid overlapping hostnames"

                if($NJOLTS.name -contains $HN2){

                    Write-host "Found an Overlapping Hostname, Cant rename remotely: $HN2" -ForegroundColor Magenta
                    
                }else{

                    "Renaming $HN To $HN2"
                    Rename-computer -Computername $IPAddr -NewName "$HN2" -DomainCredential $Cred
                    
                    Write-host "Renaming to $HN2 Completed!" -foreground Yellow -BackgroundColor Black

                }
            }else{
                
                Write-host "$HN does not contain SOMLAP, Skipping" -ForegroundColor Red
            }
        }catch{

            Write-host "Skipping $IPaddr due to no response" -ForegroundColor Magenta
    
        }
    }else{

        Write-Host "$ipAddr is Offline, Skipping" -ForegroundColor Magenta
        
    }$i++
}