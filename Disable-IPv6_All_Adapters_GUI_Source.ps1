$Adapter = Get-NetAdapterBinding |where-Object ComponentID -EQ 'ms_tcpip6' | Where-Object Name -notlike "*Bluetooth*"
"Adapters Loaded`n"
$Val = 1
function AdapterSwitch{
    $Title = "Choose options 1, 2 or 3 to proceed."
    $Info = Write-host "Would you like to enable or disable IPv6 on all adapters?" -Foregroundcolor Yellow -Backgroundcolor Black
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Enable", "&2. Disable", "&3. Quit")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
    switch($opt)
    {
        0 { 

            Write-Host "Enable IPv6" -ForegroundColor Green
            
            Foreach ($Adapt in $Adapter){

                Enable-netadapterbinding -Name $adapt.name -ComponentID 'ms_tcpip6'
                "Enabling $($Adapt.name)'s IPv6"
            }
            "`nIPv6 has been disabled from $($Adapter.Count) adapters.`n"
            $val = 0

        }
        1 { 

            Write-Host "Disable IPv6" -ForegroundColor Green
            
            Foreach ($Adapt in $Adapter){

                Disable-netadapterbinding -Name $adapt.name -ComponentID 'ms_tcpip6'
                "Disabling $($Adapt.name)'s IPv6"
            }
            "`nIPv6 has been disabled from $($Adapter.Count) adapters.`n"
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
    AdapterSwitch
}


