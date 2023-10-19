Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}

#Check Script is running with Elevated Privileges
Check-RunAsAdministrator
 

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