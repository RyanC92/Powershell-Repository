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

Function Process-PCList(){

    ForEach ($PC in $PCs){
        #Increment $i from 0 to get a count
        $i++
        #Show progress of the count
        Write-Progress -Activity "Transfering file to $PC" -Status "Count: $i of $($PCs.count)"
        
        Write-Host "Testing $PC for Activity" -ForegroundColor Green
        #Test each computer and assign the value to $tp if it returns $True, run the script, if not export an error to an error log
        $tp = Test-Connection -ComputerName $PC -quiet -Count 1

        if($tp -eq $True){
            #Write-Host "I AM ONLINE $($PC.Hostname)" 
            Write-Host "Copying to $PC" -ForegroundColor Green
    
            #Copy the file to the remote computer
            xcopy $FileToTransfer "\\$PC\C$\"
    
            #remote execute the netsh add for the wireless profile
            PsExec64.exe "\\$PC" cmd.exe /c "netsh wlan add profile filename=C:\MEDLINE.xml User=All" 
    
            #remote execute the deletion of the wireless profile XML
            PsExec64.exe "\\$PC" cmd.exe /c "del C:\MEDLINE.XML"
    
            #remote execute the deletion of the wireless profile
            PsExec64.exe "\\$PC" cmd.exe /c "netsh wlan delete profile name=excmed" 
            
            Exit
        
        }else{
          Write-Host "$PC Is Unavailable" -ForegroundColor Red 
          $PC | Select @{Name = "Hostname"; Expression = {$PC}} | Export-csv C:\CSV\FailedHostnames$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv -Append -Notypeinformation
    
        }
       
    }

}


$i = 0

Write-Host "Select the Item to Transfer" -ForegroundColor Green
#Use Function to Get the File to transfer
$FileToTransfer = Get-FileName

Write-host "Select the List of Computers to transfer the shortcut to" -ForegroundColor Green
#Use Function to Get the CSV list of Computers
$Comps = Get-FileName

#Convert $Comps to CSV and assign it to $PCS
$PCS = Import-CSV $Comps

Write-Host "Questions Answer with Y or N" -ForegroundColor Green 
$CustomCode = Read-Host "Would you like to enter custom code? Y/N"
$TransFile  = Read-Host "Are you Transferring a file? Y/N"

if($CustomCode -eq "Y"){
    
    Write-host "Custom Code to remote Execute" -ForegroundColor Yellow
    $CustCode = Read-host ""

    Process-PCList
    


}


}else{

    #Run a ForEach on each hostname in $PCs Assign it to $PC
ForEach($PC in $PCs){
    #Increment $i from 0 to get a count
    $i++
    #Show progress of the count
    Write-Progress -Activity "Transfering file to $PC" -Status "Count: $i of $($PCs.count)"
    
    Write-Host "Testing $PC for Activity" -ForegroundColor Green
    #Test each computer and assign the value to $tp if it returns $True, run the script, if not export an error to an error log
    $tp = Test-Connection -ComputerName $PC -quiet -Count 1
  
      if($tp -eq $True){
          #Write-Host "I AM ONLINE $($PC.Hostname)" 
          Write-Host "Copying to $PC" -ForegroundColor Green
  
          #Copy the file to the remote computer
          xcopy $FileToTransfer "\\$PC\C$\"
  
          #remote execute the netsh add for the wireless profile
          PsExec64.exe "\\$PC" cmd.exe /c "netsh wlan add profile filename=C:\MEDLINE.xml User=All" 
  
          #remote execute the deletion of the wireless profile XML
          PsExec64.exe "\\$PC" cmd.exe /c "del C:\MEDLINE.XML"
  
          #remote execute the deletion of the wireless profile
          PsExec64.exe "\\$PC" cmd.exe /c "netsh wlan delete profile name=excmed" 
          
          Exit
      
      }else{
        Write-Host "$PC Is Unavailable" -ForegroundColor Red 
        $PC | Select @{Name = "Hostname"; Expression = {$PC}} | Export-csv C:\CSV\FailedHostnames$([DateTime]::Now.ToSTring("MM-dd-yyyy-hh.mm.ss")).csv -Append -Notypeinformation
  
      }
     
  }

}


