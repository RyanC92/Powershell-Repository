function Check-IsElevated
 {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
   { Write-Output $true,
    "You're Set" }      
    else
   { Write-Output $false
    "Saving Path"
    $location = get-location
    Start-process powershell -verb runas -ArgumentList @("cd $($location.path)") }   
 }


 Check-IsElevated
