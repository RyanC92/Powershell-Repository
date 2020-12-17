#Script for pulling service tags from computers




Function PullSerial {

    Write-host "Please enter the IP address of the computer" -ForegroundColor Green

    $IP = Read-host "IP"
    

    $TC = Test-connection $IP -Quiet -Count 1

        if ($TC -eq $True){

            Write-host "IP is live - Executing Remote Command" -ForegroundColor Green
            psexec -nobanner \\$IP powershell Get-Wmiobject -class win32_bios | Select PSComputername, Serialnumber
            
        }else{
            Write-Host "$($IP) Test ping returned False"
        }

        $Title = Write-host "Do you need to search for more Service Tags / Serial Numbers?" -ForegroundColor Yellow -BackgroundColor Black
        $Prompt = "Enter your Choice"
        $Choices = [System.management.Automation.Host.ChoiceDescription[]] @("&Yes","&No")
        $Default = 1
        $Choice = $Host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)
        
        #Action based on the choice number in switch format
        switch($Choice) 
        {
            
            0 { $Type = "Yes"
                PullSerial
            }
            1 { $Type = "No"
                Exit
            }
        }
}

PullSerial
