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
        Import-Module ActiveDirectory -UseWindowsPowerShell 3> $null
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
$DateTag = Get-Date -Format "MM-dd-yyyy"
$ExcelPath = Join-Path $Path "PANJADDump-$DateTag.xlsx"
$CsvPattern = "*-$DateTag.csv"
$OldCsvs = Get-ChildItem -Path $Path -Filter $CsvPattern

foreach ($file in $OldCsvs) {
    try {
        Remove-Item $file.FullName -Force
        Write-Host "🗑️ Removed old CSV: $($file.Name)" -ForegroundColor DarkGray
    } catch {
        Write-Warning "⚠️ Could not delete $($file.Name): $_"
    }
}


# Ensure directory exists
if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
}

$OUs = @(
    'OU=Computers,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org',
    'OU=Computers,OU=Albany,OU=North East,OU=Offices,DC=tcco,DC=org',
    'OU=Computers,OU=Buffalo,OU=North East,OU=Offices,DC=tcco,DC=org',
    'OU=Computers,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org',
    'OU=Computers,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org',
    'OU=Computers,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org'
)

$Jobs = @()

foreach ($OU in $OUs) {
    Write-Host "Starting job for $OU" -ForegroundColor Green
    if ($OU -match 'OU=([^,]+)') {
        $OUName = $Matches[1]
    } else {
        $OUName = "UnknownOU"
    }
    $CsvPath = Join-Path $Path "$OUName-$DateTag.csv"

    $Jobs += Start-Job -ScriptBlock {
        param($OU, $CsvPath)

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
                Import-Module ActiveDirectory -UseWindowsPowerShell 3> $null
            }
        }
        $Comps = Get-ADComputer -SearchBase $OU -Filter *

        $Results = @()

        foreach ($Comp in $Comps) {
            try {
                $LAPS = Get-LapsADPassword -Identity $Comp.Name
                $PlainPassword = if ($LAPS.Password) {
                    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LAPS.Password)
                    $pw = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                    $pw
                } else {
                    "[No Password Available]"
                }

                $BitlockerKeys = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' `
                    -SearchBase $Comp.DistinguishedName -Properties whenCreated, msFVE-RecoveryPassword |
                    Sort-Object whenCreated -Descending

                $BitlockerKey = $null
                if ($BitlockerKeys) {
                    $BitlockerKey = $BitlockerKeys | Select-Object -First 1
                }

                $Results += [PSCustomObject]@{
                    ComputerName = $LAPS.ComputerName
                    DistinguishedName = $LAPS.DistinguishedName
                    Password = $PlainPassword
                    ExpirationTimeStamp = $LAPS.ExpirationTimeStamp
                    'BitlockerKey Created' = if ($BitlockerKey) { $BitlockerKey.whenCreated } else { $null }
                    'BitlockerKey' = if ($BitlockerKey) { $BitlockerKey.'msFVE-RecoveryPassword' } else { $null }
                }
            } catch {
                Write-Warning "Failed to process $($Comp.Name): $_"
            }
        }

        $Results | Export-Csv -Path $CsvPath -NoTypeInformation
    } -ArgumentList $OU, $CsvPath
}

# Wait for jobs to finish
Write-Host "⏳ Waiting for jobs to complete..." -ForegroundColor Yellow
$Jobs | Wait-Job

# Collect results
Write-Host "📦 Merging CSVs into Excel..." -ForegroundColor Cyan
$CsvFiles = Get-ChildItem $Path -Filter "*-$DateTag.csv"

$AllData = foreach ($file in $CsvFiles) {
    Import-Csv $file.FullName
Write-Host "✅ Excel report created: $ExcelPath" -ForegroundColor Green

# 🧹 Cleanup CSV files
foreach ($file in $CsvFiles) {
    try {
        Remove-Item $file.FullName -Force
        Write-Host "🗑️ Removed temp file: $($file.Name)" -ForegroundColor DarkGray
    } catch {
        Write-Warning "⚠️ Could not delete $($file.Name): $_"
    }
}

$OldFiles = (Get-Childitem $Path) | Where {$_.CreationTime -le (Get-Date).addDays(-31)}
}

Write-Host "✅ Excel report created: $ExcelPath" -ForegroundColor Green

$OldFiles = (Get-Childitem $Path) | Where {$_.CreationTime -le (Get-Date).addDays(-31)}

Foreach($File in $OldFiles){
    Write-Host "Removing $($File.Name)" -ForegroundColor DarkGray
    Remove-item "$Path\$($File.Name)"

}