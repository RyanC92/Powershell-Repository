import-module activedirectory

CD C:\Powershell-Repository

#Search Uninstall Registry for programs 
function Search-UninstallRegistry {
    param (
        [string]$ProgramName
    )
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($path in $registryPaths) {
        Get-ItemProperty $path | Where-Object { $_.DisplayName -like "*$ProgramName*" } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    }
}

#Get remote Logged on user
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

#Get Public IP
Function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

Function Get-Pass {
    -join(48..57+65..90+97..122|ForEach-Object{[char]$_}|Get-Random -C 20)
}

function find-file($name) {
    ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
            $place_path = $_.directory
            echo "${place_path}\${_}"
    }
}

<#Function Connect-ExOnline{

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

function Unlock-ADuser{

}#>
