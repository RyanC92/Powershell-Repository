Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    #$OpenFileDialog.initialDirectoiry = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
}

$CSV = Get-Filename

$CSV | ForEach{ Set-ADAccountPassword -Identity "$_.Sam" -reset -NewPassword (ConvertTo-SecureString -AsPlainText "$_.Pass") }