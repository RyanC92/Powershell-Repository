Import-module activedirectory
Import-Module importExcel

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
    "Getting Computers for $OU"
    $Comps = Get-adcomputer -SearchBase "$OU" -Filter * | select Name, DistinguishedName
    
    Foreach ($Comp in $Comps){
        
        $LAPS = Get-AdmPwdPassword $($Comp.Name)
        $BitlockerKey = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase $Comp.DistinguishedName -Properties whenCreated, msFVE-RecoveryPassword | `
        Sort whenCreated -Descending | Select whenCreated, msFVE-RecoveryPassword | Select-Object -First 1
        $ARRAY += [PSCustomObject]@{
            ComputerName = $LAPS.ComputerName
            DistinguishedName = $LAPS.DistinguishedName
            Password = $LAPS.Password
            ExpirationTimeStamp = $LAPS.ExpirationTimeStamp
            'BitlockerKey Created' = $BitlockerKey.whenCreated
            'BitlockerKey' = $($BitlockerKey.'msFVE-RecoveryPassword')
        }
        $ARRAY
    }
}$array | Export-Excel -Path "C:\Users\rcurran\Turner Construction\IS Field Staff - PANJ and NYN\NJO\Reports\PANJ_ADDump-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx" `
    -Password "S8perM!n" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow

$OldFiles = (Get-Childitem $Path) | Where {$_.CreationTime -le (Get-Date).addDays(-31)}

Foreach($File in $OldFiles){
    "Removing $($File.Name)"
    Remove-item "$Path\$($File.Name)"

}
pause