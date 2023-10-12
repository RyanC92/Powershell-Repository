Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!" -ForegroundColor DarkGreen
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

if(Get-Module -ListAvailable -name DellBIOSProvider){
    "------------------------------------------------------`n"
    Write-host "Module Installed, skipping install sequence" -ForegroundColor Green
    Start-sleep -Seconds 1
    "------------------------------------------------------`n"
}else{
    "------------------------------------------------------`n"
    Write-Host "DellBIOSProvider Module not installed, installing now.`n" -ForegroundColor Yellow
    "------------------------------------------------------`n"
    Install-Module -Name DellBIOSProvider -Confirm -Force
    Write-host "DellBiosProvider Module has been installed.`n"
    "------------------------------------------------------`n"
    Start-sleep -Seconds 1
}

Write-Host "Importing Module DellBiosProvider `n" -ForegroundColor Green
"------------------------------------------------------`n"
Import-Module DellBiosProvider

$power = Get-item DellSMBios:\POSTBehavior\PowerWarn

if($power.CurrentValue -eq "Disabled"){
    $power
    Write-Host "Power Adapter Warning Is Already Disabled.`n"
    "Nothing has been changed." 
}else{
    $power
    Write-host "Disabling Adapter Warning `n" -ForegroundColor Green
    set-Item DellSMBios:\POSTBehavior\PowerWarn "Disabled"
    Get-item DellSMBios:\POSTBehavior\PowerWarn
    Start-sleep -Seconds 1
    Write-host "Adapter Warning has been Disabled `n" -ForegroundColor Green
    "------------------------------------------------------`n"
}

pause