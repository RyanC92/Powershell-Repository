import-module activedirectory -UseWindowsPowershell

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

function Get-NextAvailableHostname {
    [CmdletBinding()]
    param(
        # e.g. NJO, PHI, PIT
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z]{2,4}$')]
        [string]$Location,

        # Range and formatting options
        [int]$Start = 1,
        [int]$End = 3000,
        [int]$Digits = 4,

        # Kept as 'LAP' to match your NJOLAP scheme; change if you ever need DSK, SRV, etc.
        [string]$DeviceType = 'LAP',

        # Optional override; by default we search the whole domain
        [string]$SearchBase
    )

    Import-Module ActiveDirectory -ErrorAction Stop

    if (-not $PSBoundParameters.ContainsKey('SearchBase') -or [string]::IsNullOrWhiteSpace($SearchBase)) {
        $SearchBase = (Get-ADDomain).DistinguishedName
    }

    $prefix = ($Location.ToUpper() + $DeviceType.ToUpper())
    
    "Searching..."
    # Pull all existing names with that prefix across the domain
    $existing = Get-ADComputer -SearchBase $SearchBase -SearchScope Subtree `
        -Filter "Name -like '$prefix*'" -ResultSetSize $null |
        Select-Object -ExpandProperty Name

    # Fast membership checks
    $set = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($n in $existing) { [void]$set.Add($n.ToUpper()) }

    cls
    "Available Host Name Found:"    
    
    for ($i = $Start; $i -le $End; $i++) {
        $hostname = ("{0}{1:D$Digits}" -f $prefix, $i)
        if (-not $set.Contains($hostname.ToUpper())) {
            return $hostname
        }
    }

    Write-Warning "No available hostname found for prefix '$prefix' between $Start and $End."
    return $null
}