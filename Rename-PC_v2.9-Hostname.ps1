# Created by Ryan Curran
# Date: 5/14/2024

$cred = Get-Credential
$NJOLTS = get-adcomputer -filter {(Name -like "NJOLAP*")} | Select-Object Name
$SOMLTS = Get-adcomputer -filter {Name -like "SOMLAP*"} | Select-object Name

$i = 1
$j = 0
$TriedNumbers = @() # Track tried numbers

# Function to find the next available number, skipping those already tried
function Get-NextAvailableNumber {
    param (
        [int[]]$AllNumbers,
        [int[]]$ExistingNumbers,
        [int[]]$TriedNumbers
    )

    $NextAvailable = Compare-Object $AllNumbers $ExistingNumbers -PassThru | Sort-Object

    foreach ($number in $NextAvailable) {
        # Check if the number has already been tried
        if ($TriedNumbers -notcontains $number) {
            return $number
        }
    }

    return $null # If no available number is found
}

foreach ($LT in $SOMLTS) {
    '-------------'
    "Processing: $i"
    $Online = Test-Connection $LT.name -Quiet -count 1
    "Testing Result: $($LT.name) Online Status is $online"

    if ($online -eq $True) {
        Write-host "Querying: $($LT.Name)" -ForegroundColor Green

        try {
            $HN = Get-wmiobject -ComputerName $LT.Name -Class Win32_ComputerSystem -Erroraction stop -Credential $cred | Select-Object -ExpandProperty Name

            Write-host "Response Received `nName is: $HN" -ForegroundColor DarkGreen
            "Remote Hostname Gathered: $HN"

            try {
                if ($HN -eq "$($LT.Name)") {

                    "Finding Next Available Hostname"
                    $ExistingNumbers = $NJOLTS.Name | ForEach-Object { [int]($_ -replace '.*?(?=\d+$)') }

                    # Find the next available number (skip those already tried)
                    $NextAvailableNumber = Get-NextAvailableNumber -AllNumbers (1..450) -ExistingNumbers $ExistingNumbers -TriedNumbers $TriedNumbers

                    if ($NextAvailableNumber -ne $null) {
                        # Create the new hostname
                        $NewComputerName = '{0}{1:D4}' -f 'NJOLAP', ($NextAvailableNumber)
                        "New Computer Name will be: $NewComputerName"
                        "Attempting Renaming from $HN to $NewComputerName..."

                        try {
                            Rename-computer -Computername $($LT.Name) -NewName "$NewComputerName" -DomainCredential $Cred
                            Write-host "Renaming to $NewComputerName Completed!" -foreground Yellow -BackgroundColor Black

                            # Add the number to the tried list after successful rename
                            $TriedNumbers += $NextAvailableNumber
                        } catch {
                            Write-Warning "Renaming the computer failed for hostname $($LT.Name)"
                        }

                        $j++

#                         $Comment = "Your computer is set to restart at 5PM for an update, if you can restart prior to 5PM please do so. Thank you. - Ryan Curran"
                        
#                         # Get the current time
#                         $CurrentTime = Get-Date
#                         # Set the target time to 5 PM
#                         $TargetTime = Get-Date -Hour 17 -Minute 0 -Second 0
#                         # Calculate the time difference in seconds
#                         $TimeDifferenceInSeconds = [int]($TargetTime - $CurrentTime).TotalSeconds
                        
#                         # Output the result
#                         Write-Output "Time difference in seconds: $TimeDifferenceInSeconds"
                        
#                         $script = @"
#                         `$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /t $($TimeDifferenceInSeconds) /c `$($Comment)'
#                         `$Trigger = new-scheduledtasktrigger -Once -At (Get-Date)
#                         Register-ScheduledTask -Action `$Action -Trigger `$trigger -TaskName 'Rename-Reboot' -Description 'Reboots the computer at Time - 5PM EST'
#                         Start-ScheduledTask -TaskName 'Rename-Reboot'  
# "@
                        
#                         # Convert the script to base64:
#                         $bytes = [System.Text.Encoding]::Unicode.GetBytes($script)
#                         $encodedCommand = [Convert]::ToBase64String($bytes)
                        
#                         # Run psexec with the encoded command
#                         psexec.exe \\$NewComputerName powershell -EncodedCommand $encodedCommand
                        
                    } else {
                        Write-Warning "No available NJOLAP numbers found."
                    }
                } else {
                    Write-Warning "$HN is either already NJOLAP or does not contain SOMLAP, Skipping"
                }
            } catch {
                Write-Warning "Skipping $($LT.Name) due to no response"
            }
        } catch {
            Write-Warning "RPC Server is unavailable for $($LT.Name), Skipping"
        }
    } else {
        Write-Warning "$($LT.Name) is Offline, Skipping"
    }
    $i++
}

$OLDLTS2 = get-adcomputer -filter {(Name -like "SOMLAP*") -and (Enabled -eq $True)} | Measure-Object
$NEWLTS2 = get-adcomputer -filter {(Name -like "NJOLAP*") -and (Enabled -eq $True)} | Measure-Object

' ------------------------------------------------------- '
"| There are $($OLDLTS2.Count) Old Computers Remaining   |"
"| There are $($NEWLTS2.Count) New Computers Now         |"
"| $j Computers were renamed during this cycle           |"
' ------------------------------------------------------- '