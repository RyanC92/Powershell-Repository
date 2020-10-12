#Run to install SharepointPnPOnline Module
Invoke-Expression (New-Object -TypeName Net.WebClient).DownloadString('https://raw.githubusercontent.com/officedev/PnP-PowerShell/master/Samples/Modules.Install/Install-PowerShellPackageMangement.ps1') # We use this to install the PowerShell Package Manager for the PowerShell Gallery
Invoke-Expression (New-Object -TypeName Net.WebClient).DownloadString('https://raw.githubusercontent.com/officedev/PnP-PowerShell/master/Samples/Modules.Install/Install-SharePointPnPPowerShellHelperModule.ps1')
#Updates the Module after being installed
Update-module Sharepointpnppowershell* -force
#Ready to Run. Test by typing Connect-Pnpo and pressing Tab to see if it auto completes the command.