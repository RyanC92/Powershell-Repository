# Function to check if a specific program is installed by searching the registry
function Is-ProgramInstalled {
    param (
        [string]$ProgramName
    )

    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    foreach ($path in $registryPaths) {
        $keys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($key in $keys) {
            $displayName = (Get-ItemProperty -Path $key.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*$ProgramName*") {
                Write-Host "$ProgramName is already installed."
                return $true
            }
        }
    }

    return $false
}

# Function to check for .NET Framework 4.8 installation
function Is-DotNet48Installed {
    $regKey = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $release = (Get-ItemProperty -Path $regKey).Release
    if ($release -ge 528040) {
        Write-Host ".NET Framework 4.8 is already installed."
        return $true
    }
    return $false
}

# Function to install a program
function Install-Program {
    param (
        [string]$ProgramName,
        [string]$InstallerPath,
        [string]$InstallerArgs
    )

    if (-not (Is-ProgramInstalled -ProgramName $ProgramName)) {
        Write-Host "Installing $ProgramName..."
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $InstallerArgs -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host "$ProgramName installed successfully."
            return $true
        } else {
            Write-Host "Failed to install $ProgramName. Exit Code: $($process.ExitCode)"
            return $false
        }
    } else {
        Write-Host "Skipping $ProgramName installation as it is already installed."
        return $true
    }
}

# Function to install .NET Framework 4.8
function Install-DotNet48 {
    param (
        [string]$InstallerPath,
        [string]$InstallerArgs
    )

    if (-not (Is-DotNet48Installed)) {
        Write-Host "Installing .NET Framework 4.8..."
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $InstallerArgs -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host ".NET Framework 4.8 installed successfully."
            return $true
        } else {
            Write-Host "Failed to install .NET Framework 4.8. Exit Code: $($process.ExitCode)"
            return $false
        }
    } else {
        Write-Host "Skipping .NET Framework 4.8 installation as it is already installed."
        return $true
    }
}

# Define the list of programs to install with paths and arguments
$prereqs = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Path = '.\vcredist_x64_2013.exe';
        Args = '/install /quiet /norestart'
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2019 Redistributable';
        Path = '.\vc_redist.x64.exe';
        Args = '/install /quiet /norestart'
    }
)

# Define the .NET Framework 4.8 installer
$dotNetInstaller = @{
    Path = 'C:\Installers\ndp48-x86-x64-allos-enu.exe';
    Args = '/q /norestart'
}

# Loop through and install each Visual C++ Redistributable
foreach ($prereq in $prereqs) {
    $result = Install-Program -ProgramName $prereq.Name -InstallerPath $prereq.Path -InstallerArgs $prereq.Args
    if (-not $result) {
        Write-Host "Stopping further installations due to failure in installing $($prereq.Name)."
        exit 1
    }
}

# Install .NET Framework 4.8
$dotNetResult = Install-DotNet48 -InstallerPath $dotNetInstaller.Path -InstallerArgs $dotNetInstaller.Args
if (-not $dotNetResult) {
    Write-Host "Stopping further installations due to failure in installing .NET Framework 4.8."
    exit 1
}

# Uninstall Validation Client

# Install SAP .Net Connector

# Install SAP SCE 7.5

# Install SAP Validation Client

Write-Host "All programs installed successfully."
