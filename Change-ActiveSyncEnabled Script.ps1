#Change ActiveSyncEnabled Status

Write-Output "Select CSV Path"

Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    #$OpenFileDialog.initialDirectoiry = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
}

$CSV = Get-Filename



$Option = Read-Host "Press 1 to Set ActiveSyndEnabled to $True or Press 2 to set ActiveSyncEnabled to $False"

if($Option -eq "1"){

    $CSV | ForEach(Set-CASMailbox -Identity $_.UserPrincipalName -ActiveSyncEnabled $True)

}

elseif($Option -eq "2"){

    $CSV | ForEach(Set-CASMailbox -Identity $_.UserPrincipalName -ActiveSyncEnabled $False)

}



elseif($option -ne "1" -or "2"){

    Write-Host "Option 1 or 2 has not been chosen, no action has been taken"

}