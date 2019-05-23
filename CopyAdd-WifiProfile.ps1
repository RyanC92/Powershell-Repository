#Reference Change-BulkPW_Reset.ps1 for more details on a finished script.

Function Get-FileName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.Dereferencelinks = $False
  $OpenFileDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName
}
Function Get-FolderName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  #$OpenFolderDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFolderDialog.ShowDialog() | Out-Null
  $OpenFolderDialog.SelectedPath
}

$i = 0

Write-Host "Select the Shortcut to Transfer" -ForegroundColor Green
$Shortcut = Get-FileName

Write-host "Select the List of Computers to transfer the shortcut to" -ForegroundColor Green
$Comps = Get-FileName

$XML = $Shortcut
$PCS = Import-CSV $Comps

Write-Host "You Selected the Path $XML" -ForegroundColor Green


ForEach($PC in $PCs){
  $i++
  Write-Progress -Activity "Installing new MEDLINE SSID" -Status "Installed: $i of $($PCs.count)"

  Write-Host "Testing $($PC.Hostname) for Activity"

  $tp = Test-Connection -ComputerName $PC.Hostname -quiet -Count 1

    if($tp -eq $True){
      Write-Host "I AM ONLINE $($PC.Hostname)" 
      <#Write-Host "Copying to $($PC.Hostname)" -ForegroundColor Green
      xcopy $XML "\\$($PC.Hostname)\C$\"


      PsExec64.exe "\\$($PC.Hostname)" cmd.exe /c "netsh wlan add profile filename=C:\MEDLINE.xml User=All" 

      PsExec64.exe "\\$($PC.Hostname)" cmd.exe /c "netsh wlan delete profile name=excmed" 

      Start-Sleep -Seconds 2

      PsExec64.exe "\\$($PC.Hostname)" cmd.exe /c "del C:\MEDLINE.XML"
    #>
    }else{
      Write-Host "$($PC.Hostname) Is Unavailable" -ForegroundColor Red 
      $PC | Select @{Name = "Hostname"; Expression = {$($PC.Hostname)}} | Export-csv C:\CSV\FailedHostnames.csv -Append

    }
  

  
}

