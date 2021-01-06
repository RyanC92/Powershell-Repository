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

Write-host "Select the List of Computers to Update" -ForegroundColor Green
#Use Function to Get the CSV list of Computers
$Comps = Get-FileName

$PCS = Import-csv $Comps

ForEach ($PC in $PCS){

    $i++ 
    
    #Show progress of the count
    Write-Progress -Activity "Updating Descriptions" -Status "Updating: $i of $($PCs.count)"
    Write-Host "Updating $($PC.Name)"

    Set-adcomputer -Identity $PC.Name -Description $PC.Description

}