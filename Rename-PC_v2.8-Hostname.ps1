#Created by Ryan Curran
#Date: 5/14/2024
$cred = Get-Credential
$NJOLTS = get-adcomputer -filter {(Name -like "NJOLAP*")} | Select-Object Name
$SOMLTS = Get-adcomputer -filter {Name -like "SOMLAP*"} | Select-object Name

$i = 1
$j = 0
foreach($LT in $SOMLTS){
    '-------------'
    "Processing: $i"
    $Online = Test-Connection  $LT.name -Quiet -count 1
    "Testing Result:$($LT.name) Online Status is $online"

    if($online -eq $True){

        Write-host "Querying: $($LT.Name)" -ForegroundColor Green

        try{            
            $HN = Get-wmiobject -ComputerName $LT.Name -Class Win32_ComputerSystem -Erroraction stop | Select-Object -ExpandProperty Name

            Write-host "Response Received `nName is: $HN" -ForegroundColor DarkGreen
            "Gathered Remote Hostname"

            try{
                if($HN -like "$($LT.Name)"){
                    
                    "Finding Next Available Hostname"
                    
                    $NJOLTS = get-adcomputer -filter {Name -like "NJOLAP*"} | Select-Object Name
                    $FNN = Compare-object(0001..0450) ($njolts.name -replace '.*?(?=\d+$)' -as [int[]]) -PassThru
                    $NewComputerName = '{0}{1:D4}' -f 'NJOLAP',($FNN[0])
                    
                    "New Computer Name will be: $NewComputerName"
                    "Attempting Renaming from $HN to $NewComputerName..."
                    
                    try{
                        Rename-computer -Computername $($LT.Name) -NewName "$NewComputerName" -DomainCredential $Cred
                        Write-host "Renaming to $NewComputerName Completed!" -foreground Yellow -BackgroundColor Black
                    }catch{
                        Write-Warning "Renaming the computer failed for hostname $($LT.Name)"
                    }
                    j++

                    $StartDate = (GET-DATE -Hour 17 -Minute 0 -Second 0) #time 5PM
                    $Comment = "Your computer is set to restart at 5PM for an update, if you can restart prior to 5PM please do so. Thank you. - Ryan Curran"
                    # Get the current time
                    $CurrentTime = Get-Date
                    # Set the target time to 5 PM
                    $TargetTime = Get-Date -Hour 17 -Minute 0 -Second 0
                    # Calculate the time difference in seconds
                    $TimeDifferenceInSeconds = [int]($TargetTime - $CurrentTime).TotalSeconds
                    # Output the result
                    Write-Output "Time difference in seconds: $TimeDifferenceInSeconds"
                    psexec.exe \\$LT.Name powershell
                        "$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /t $($TimeDifferenceInSeconds) /c '$($Comment)''"
                        "$Trigger = new-scheduledtasktrigger -Once -At (Get-Date)"
                        "Register-ScheduledTask -Action $Action -Trigger $trigger -TaskName 'Rename-Reboot' -Description 'Reboots the computer at Time - 5PM EST'"
                        Exit
                    # Invoke-WmiMethod -Computername 172.18.47.82 -Class Win32_OperatingSystem -Name Win32Shutdowntracker -ArgumentList @($($NTS.TotalSeconds), $Comment, 0, 2)
                    # $Reboot = @("/r", "/t", $($NTS.TotalSeconds),"/c", "TEsttest"
                    # "Setting Reboot time for $($NTS.TotalSeconds) Seconds (5PM today)
                    # shutdown.exe /m \\$IPAddr /r /t $NTS.TotalSeconds /c "Your computer is set to restart at 5PM for an update, if you can restart prior to 5PM please do so. Thank you. -Ryan Curran"
                    
                
                }else{
                    
                    Write-Warning "$HN is either already NJOLAP or does not contain SOMLAP, Skipping"
    
                }
            }catch{
                Write-Warning "Skipping $($LT.Name) due to no response"
            }
        }catch{
            Write-Warning "RPC Server is unavailable for $($LT.Name), Skipping"
        }
    }else{

        Write-Warning "$($LT.Name) is Offline, Skipping"
        
    }$i++
}

$OLDLTS2 = get-adcomputer -filter {(Name -like "SOMLAP*") -and (Enabled -eq $True)} | Measure-Object
$NEWLTS2 = get-adcomputer -filter {(Name -like "NJOLAP*") -and (Enabled -eq $True)} | Measure-Object
' ------------------------------------------------------- '
"| There are $($OLDLTS2.Count) Old Computers Remaining   |"
"| There are $($NEWLTS2.Count) New Computers Now         |"
"| $j Computers were renamed during this cycle           |"
' ------------------------------------------------------- '
