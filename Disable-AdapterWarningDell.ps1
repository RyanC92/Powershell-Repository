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

if(Get-Module -ListAvailable -name DellBIOSProvider){
    "------------------------------------------------------"
    Write-host "Module Installed, skipping install sequence" -ForegroundColor Green
    "------------------------------------------------------"
}else{
    "------------------------------------------------------"
    Write-Host "DellBIOSProvider Module not installed, installing now." -ForegroundColor Yellow
    Install-Module -Name DellBIOSProvider -Confirm -Force
    Write-host ""
    "------------------------------------------------------"
}

Write-Host "Importing Module DellBiosProvider" -ForegroundColor Green
Import-Module DellBiosProvider

"------------------------------------------------------"
Write-host "Disabling Adapter Warning" -ForegroundColor Green
set-Item DellSMBios:\POSTBehavior\PowerWarn "Disabled"
Start-sleep -Seconds 2
Write-host "Adapter Warning Disabled" -ForegroundColor Green
"------------------------------------------------------"