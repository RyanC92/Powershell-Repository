Write-Host "---------------------------" -Foregroundcolor Green
Write-Host "| Created By: Ryan Curran |" -ForegroundColor Green
Write-Host "---------------------------" -ForegroundColor Green

"`n"

"This patch will work for 20.x.x version of Bluebeam only (currently)`n"
function UpdateSwitch{
    $Title = "Choose options 1, 2 or 3 to proceed."
    $Info = Write-host "Would you like to enable or disable Bluebeam update prompt (Help -> Check For Updates)?" -Foregroundcolor Yellow -Backgroundcolor Black
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Enable", "&2. Disable", "&3. Quit")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
    switch($opt)
    {
        0 { 
            cls

            Write-Host "---------------------------" -Foregroundcolor Green
            Write-Host "| Created By: Ryan Curran |" -ForegroundColor Green
            Write-Host "---------------------------" -ForegroundColor Green

            "`n"
            
            Write-Host "Option Selected: Enabling Bluebeam Updates." -ForegroundColor Green
            
            Set-ItemProperty -Path "HKLM:\Software\Bluebeam Software\20\Revu" -Name "DisableInAppUpdates" -Value "0"
                
            Write-Host "`nBluebeam Updates has been Enabled.`n" -ForegroundColor Green
            Write-Host "`nClose and re-open Bluebeam for the changes to take effect.`n" -ForegroundColor Green

            $val = 0

        }
        1 { 
            cls

            Write-Host "---------------------------" -Foregroundcolor Green
            Write-Host "| Created By: Ryan Curran |" -ForegroundColor Green
            Write-Host "---------------------------" -ForegroundColor Green

            "`n"
            Write-Host "Option Selected: Disable Bluebeam Updates." -ForegroundColor Green
            
            Set-ItemProperty -Path "HKLM:\Software\Bluebeam Software\20\Revu" -Name "DisableInAppUpdates" -Value "1"
                
            Write-Host "`nBluebeam Updates has been Disabled.`n" -ForegroundColor Green
            Write-Host "`nClose and re-open Bluebeam for the changes to take effect.`n" -ForegroundColor Green

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