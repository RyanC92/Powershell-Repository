$Title = ""
$Info = Write-host "Would you like to scan directories, files or both? (Please note, scanning for both will drastically increase your scantime)" -Foregroundcolor Yellow -Backgroundcolor Black
  
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1. Directories", "&2. Files", "&3. Both (Directories & Files)", "&4. Quit")
[int]$defaultchoice = 0
$opt = $host.UI.PromptForChoice($Title, $Info , $Options,$defaultchoice)
switch($opt)
{
0 { Write-Host "Directories" -ForegroundColor Green}
1 { Write-Host "Files" -ForegroundColor Green}
2 { Write-Host "Both" -ForegroundColor Green}
3 {Write-Host "Quit" -ForegroundColor Green}
}
