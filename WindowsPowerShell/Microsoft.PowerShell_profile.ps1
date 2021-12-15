import-module activedirectory

CD C:\Powershell-Repository


Function Connect-2016{

$Credential = Get-Credential -Credential pa-rcurran

Write-Output "Getting Exchange Online cmdlets"

$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri <sharepointpowershellurl> -Authentication Kerberos -Credential $Credentials

Import-PSSession $session


}


Function Connect-ExOnline{

$Credential = Get-Credential -Credential Rcurran@excelsiormedical.com

Write-Output "Getting Exchange Online cmdlets"

$session = New-PSSession -ConnectionUri https://ps.outlook.com/Powershell `
    -ConfigurationName Microsoft.Exchange -Credential $Credential `
    -Authentication Basic -AllowRedirection
Import-PSSession $session

Connect-MsolService -Credential $Credential

}

Function PWchange{

$User = Read-Host "User Email Address:"
$Password = Read-Host "Enter New Password"

Set-Msoluserpassword -UserPrincipalName $User -NewPassword $Password -ForceChangePassword $False 

}

function Get-LoggedOnUser
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    foreach ($comp in $ComputerName)
    {
        $output = @{ 'ComputerName' = $comp }
        $output.UserName = (Get-WmiObject -Class win32_computersystem -ComputerName $comp).UserName
        [PSCustomObject]$output
    }
}