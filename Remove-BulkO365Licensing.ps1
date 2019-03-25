Write-Host "Select a CSV File for Importing"

Function Get-Path
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    #$OpenFileDialog.initialDirectoiry = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
}

$CSV = Get-Path

$Option = Read-Host "1 To Remove User Licenses"

if($Option -eq "1") {

$CSV | % { Set-MsoluserLicense -UserPrincipalName $_.email -RemoveLicenses "EXCELSIORMEDICAL:VISIOCLIENT" , "EXCELSIORMEDICAL:PROJECTCLIENT" , "EXCELSIORMEDICAL:EXCHANGEDESKLESS" , "EXCELSIORMEDICAL:EXCHANGESTANDARD" , "EXCELSIORMEDICAL:OFFICESUBSCRIPTION" , "EXCELSIORMEDICAL:EXCHANGEARCHIVE" , "EXCELSIORMEDICAL:O365_BUSINESS" } | Out-File C:\CSV\Results.txt

}

elseif ($Option -ne "1"){

Write-Host "No Changes were Made, Be More Careful Next Time."

}
