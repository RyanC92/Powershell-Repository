function UpdateSwitch{
    $Title = "Choose options 1, 2 or 3 to proceed."
    $Info = Write-host "Would you like to enable or disable Bluebeam updates?" -Foregroundcolor Yellow -Backgroundcolor Black
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Enable", "&2. Disable", "&3. Quit")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
    switch($opt)
    {
        0 { 

            Write-Host "Enabling Bluebeam Updates" -ForegroundColor Green
            
                Set-ItemProperty -Path "HKLM:\Software\Bluebeam Software\20\Revu" -Name "DisableInAppUpdates" -Value "0"
                
            "`nBluebeam Updates has been Enabled.`n"
            $val = 0

        }
        1 { 

            Write-Host "Disable Bluebeam Updates" -ForegroundColor Green
            
            Set-ItemProperty -Path "HKLM:\Software\Bluebeam Software\20\Revu" -Name "DisableInAppUpdates" -Value "1"
                
            "`nBluebeam Updates has been Disabled.`n"

            $val = 1

        }
        2 { 

            Write-Host "Quit" -ForegroundColor Red
            $val = 2
            Exit
        }
    }
}

While($val -ne 2){
    UpdateSwitch
}