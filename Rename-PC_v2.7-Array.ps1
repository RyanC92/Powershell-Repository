$iprange = @(2..253)
$cred = Get-Credential
$NJOLTS = get-adcomputer -filter {(Name -like "NJOLAP*")} | Select-Object Name

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
            $HN = Get-wmiobject -ComputerName $IPAddr -Class Win32_ComputerSystem -Erroraction stop | Select-Object -ExpandProperty Name

            Write-host "Response Received `nName is: $HN" -ForegroundColor DarkGreen
            "Gathered Remote Hostname"

            try{
                if($HN -like "SOMLAP*"){
                    
                    "Finding Next Available Hostname"
                    
                    $NJOLTS = get-adcomputer -filter {(Name -like "NJOLAP*")} | Select-Object Name
                    #Not working properly, needs to properly pull the NEXT number that is available.
                    <#$searcher = [ADSISearcher]'(&(objectCategory=computer)(name=NJOLAP*))'
                    $searcher.PageSize = 1000
                    $last = $searcher.FindAll() | Foreach-Object { [int]($_.Properties.name -replace '\D').Trim() } | Sort-Object | Select-Object -Last 1
                    #>
                    $FNN = Compare-object(0001..0450) ($njolts.name -replace '.*?(?=\d+$)' -as [int[]]) -PassThru
                    $NewComputerName = '{0}{1:D4}' -f 'NJOLAP',($FNN[0])
                    $Newcomputername
                    
                    "New Computer Name will be: $NewComputerName"
                    "Attempting Renaming from $HN to $NewComputerName..."
                    
                    Rename-computer -Computername $IPAddr -NewName "$NewComputerName" -DomainCredential $Cred
                    
                    Write-host "Renaming to $NewComputerName Completed!" -foreground Yellow -BackgroundColor Black


                    # $StartDate = (GET-DATE)
                    # $EndDate = [datetime]"17:00"
                    # $NTS = New-Timespan -Start $StartDate -End $EndDate
                    # $NTS = $NTS.TotalSeconds
                    # $Comment = "Your computer is set to restart at 5PM for an update, if you can restart prior to 5PM please do so. Thank you. -Ryan Curran"

                    psexec.exe \\$IPaddr powershell
                        "$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /t 3600 /c 'Your Computer Will Reboot for updates in 1 Hour, Please Save Your Work.''"
                        "$Trigger = new-scheduledtasktrigger -Once -At 4PM"
                        "Register-ScheduledTask -Action $Action -Trigger $trigger -TaskName 'Reboot_1_Hour' -Description 'Reboot in 1 Hour'"
                        Exit
                    # Invoke-WmiMethod -Computername 172.18.47.82 -Class Win32_OperatingSystem -Name Win32Shutdowntracker -ArgumentList @($($NTS.TotalSeconds), $Comment, 0, 2)
                    # $Reboot = @("/r", "/t", $($NTS.TotalSeconds),"/c", "TEsttest"
                    # "Setting Reboot time for $($NTS.TotalSeconds) Seconds (5PM today)
                    # shutdown.exe /m \\$IPAddr /r /t $NTS.TotalSeconds /c "Your computer is set to restart at 5PM for an update, if you can restart prior to 5PM please do so. Thank you. -Ryan Curran"
                    
                
                }else{
                    
                    Write-Warning "$HN is either already NJOLAP or does not contain SOMLAP, Skipping"
    
                }
            }catch{
                Write-Warning "Skipping $IPaddr due to no response"
            }
        }catch{
            Write-Warning "RPC Server is unavailable, Skipping"
        }
    }else{

        Write-Warning "$ipAddr is Offline, Skipping"
        
    }$i++
}

$OLDLTS2 = get-adcomputer -filter {(Name -like "SOMLAP*") -and (Enabled -eq $True)} | Measure-Object
$NEWLTS2 = get-adcomputer -filter {(Name -like "NJOLAP*") -and (Enabled -eq $True)} | Measure-Object
' ------------------------------------------------------- '
"| There are $($OLDLTS2.Count) Old Computers Remaining   |"
"| There are $($NEWLTS2.Count) New Computers Now         |"
' ------------------------------------------------------- '
