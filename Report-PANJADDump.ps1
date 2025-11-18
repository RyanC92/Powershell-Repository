if ($PSVersionTable.PSVersion.Major -eq 5) {
    # Windows PowerShell 5.1
    Import-Module ActiveDirectory
}
elseif ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7+
    try {
        # Try native load first
        Import-Module ActiveDirectory -SkipEditionCheck -ErrorAction Stop
    } catch {
        Write-Warning "Native load failed. Falling back to compatibility mode."
        Import-Module ActiveDirectory -UseWindowsPowerShell
    }
}

if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    try {
        Write-Host "📦 ImportExcel module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name ImportExcel -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "✅ ImportExcel module installed successfully." -ForegroundColor Green
    } catch {
        Write-Warning "❌ Failed to install ImportExcel: $_"
    }
} else {
    Write-Host "✔️ ImportExcel module is already available." -ForegroundColor Cyan
}


$Path = "C:\Users\rcurran\Turner Construction\IS Field Staff - PANJ and NYN\NJO\Reports"

$OUs = @(
    'OU=Computers,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Computers,OU=Albany,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Computers,OU=Buffalo,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org'
    'OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org'
    'OU=Computers,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org'
    )

    $Array = @()

Foreach ($OU in $OUs){
    Write-host "Getting Computers for $OU" -ForegroundColor Green
    $Comps = Get-adcomputer -SearchBase "$OU" -Filter * | select Name, DistinguishedName
    

    foreach ($Comp in $Comps) {
        $LAPS = Get-LapsADPassword -Identity $($Comp.Name)

        if ($LAPS.Password -ne $null) {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LAPS.Password)
            $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        } else {
            $PlainPassword = "[No Password Available]"
        }

        $BitlockerKey = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' `
            -SearchBase $Comp.DistinguishedName -Properties whenCreated, msFVE-RecoveryPassword |
            Sort-Object whenCreated -Descending | Select-Object -First 1

        $ARRAY += [PSCustomObject]@{
            ComputerName = $LAPS.ComputerName
            DistinguishedName = $LAPS.DistinguishedName
            Password = $PlainPassword
            ExpirationTimeStamp = $LAPS.ExpirationTimeStamp
            'BitlockerKey Created' = $BitlockerKey.whenCreated
            'BitlockerKey' = $BitlockerKey.'msFVE-RecoveryPassword'
        }
    }
}

$array
Write-host "Creating Report - PANJ_ADDump-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx" -ForegroundColor Green
$array | Export-Excel -Path "C:\Users\rcurran\Turner Construction\IS Field Staff - PANJ and NYN\NJO\Reports\PANJ_ADDump-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx" `
    -Password "S8perM!n" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow

$OldFiles = (Get-Childitem $Path) | Where {$_.CreationTime -le (Get-Date).addDays(-31)}

Foreach($File in $OldFiles){
    "Removing $($File.Name)"
    Remove-item "$Path\$($File.Name)"

}