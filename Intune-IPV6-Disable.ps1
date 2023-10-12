$Adapter = Get-NetAdapterBinding | where-Object ComponentID -EQ 'ms_tcpip6' | Where-Object Name -notlike "*Bluetooth*"

Foreach ($Adapt in $Adapter){

                Disable-netadapterbinding -Name $adapt.name -ComponentID 'ms_tcpip6'
                "Disabling $($Adapt.name)'s IPv6"
            }