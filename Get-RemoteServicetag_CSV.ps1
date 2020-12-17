#Script for pulling service tags from computers

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

$i = 0

Write-host "Select the List of Computers to Pull Data From" -ForegroundColor Green
#Use Function to Get the CSV list of Computers
$Comps = Get-FileName

$PCS = Import-csv $Comps

Write-host "What is your IP(VPN if off network) or Hostname" -ForegroundColor Green
$HN = Read-Host "IP or Hostname"


ForEach($PC in $PCS){

    $i++ 
    
    #Show progress of the count
    Write-Progress -Activity "Pulling Data from List" -Status "Testing Ping on: $i of $($PCs.count)"
    Write-Host "Testing $($PC.'Computer Name')"
   
    $TC = Test-connection $($PC.'IPv4 Addresses') -Quiet -Count 1


    if ($TC -eq $True){

        Write-Host "Connecting to $($PC.'Computer Name') and Pulling Serial Number" -ForegroundColor Green
        psexec -nobanner \\172.16.155.119 -u tcco\rcurran -p  powershell Get-Wmiobject -class win32_bios | Select PSComputername, Serialnumber | Set-Content \\$($HN)\Temp\ServiceTags$([DateTime]::Now.ToSTring("MM-dd-yyyy")).csv -append
        $SN = wmic bios get serialnumber
        $HN = Hostname
        $SN | Select @{Name = "Serial Number";Expression = {${$SN.SerialNumber}}}, @{Name = "HostName";Expression = {$HN}} | Set-Content \\SOMLAP0107\C$\Temp\Export.csv
        
        exit

        }else{

        Write-Host "$($PC.'Computer Name') Failed the Ping Test" -ForegroundColor Red
        $PC | Select @{Name = "Computer Name"; Expression = {$($PC.'Computer Name')}}, @{Name = "Last user"; Expression = {$($PC.'Last User')}}, @{Name = "Last Active"; Expression = {$($PC.'Last Active')}} | Export-csv C:\Temp\FailedHostnames.csv -Append -NoTypeinformation
        }

}