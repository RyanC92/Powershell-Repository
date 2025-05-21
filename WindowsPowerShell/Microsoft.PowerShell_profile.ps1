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

function Get-PassPhrase {
    [CmdletBinding()]
    param (
        [int]$Length = 2
    )

    $cacheDir = "$env:LOCALAPPDATA\PassphraseGen"
    #$cacheFile = Join-Path $cacheDir "words_alpha.txt"
    $cacheFile = Join-Path $cacheDir "5000-words.txt"
    $url = "https://raw.githubusercontent.com/mahsu/IndexingExercise/refs/heads/master/5000-words.txt"
   # $url = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"

    # Ensure cache directory exists
    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir | Out-Null
    }

    # Download file if not cached
    if (-not (Test-Path $cacheFile)) {
        Write-Host "📥 Downloading word list..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $url -OutFile $cacheFile -UseBasicParsing
            Write-Host "✅ Word list retrieved and cached." -ForegroundColor Green
        } catch {
            Write-Error "❌ Failed to download word list: $_"
            return
        }
    } else {
        Write-Host "📁 Using cached word list..." -ForegroundColor Yellow
    }

    $lines = Get-Content -Path $cacheFile
    $lineCount = $lines.Count
    Write-Host "📊 $lineCount words loaded." -ForegroundColor Cyan

    if ($lineCount -lt $Length) {
        Write-Error "❌ Not enough words in the list."
        return
    }

    # Inner function to build a passphrase
    function New-Phrase {
        $selectedWords = @()
        for ($i = 0; $i -lt $Length; $i++) {
            $index = Get-Random -Maximum $lineCount
            $word = $lines[$index].Trim()
            $selectedWords += $word
        }

        $targetIndex = Get-Random -Maximum $Length
        $digit = Get-Random -Maximum 10
        $selectedWords[$targetIndex] += $digit

        $capIndex = Get-Random -Maximum $Length
        $selectedWords[$capIndex] = $selectedWords[$capIndex].Substring(0,1).ToUpper() + $selectedWords[$capIndex].Substring(1)

        return $selectedWords -join "-"
    }

    # Generate and display 3 passphrases
    Write-Host "`n🔐 Your Password Options:" -ForegroundColor Magenta
    1..3 | ForEach-Object {
        $phrase = New-Phrase
        Write-Host "`n$phrase" -ForegroundColor White
    }
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
