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
                Write-Output "$ProgramName is already installed."
                return 0
            }
        }
    }

    return 1
}

# Function to check for .NET Framework 4.8 installation
function Is-DotNet48Installed {
    $regKey = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $release = (Get-ItemProperty -Path $regKey).Release
    if ($release -ge 533320) {
        Write-Output ".NET Framework 4.8 is already installed."
        return 0
    }
    return 1
}

# Function to install a program
function Install-Program {
    param (
        [string]$ProgramName,
        [string]$InstallerPath
    )

    if (-not (Is-ProgramInstalled -ProgramName $ProgramName)) {
        Write-Output "Installing $ProgramName..."
        $process = Start-Process -FilePath $InstallerPath -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Output "$ProgramName installed successfully."
            return 0
        } else {
            Write-Output "Failed to install $ProgramName. Exit Code: $($process.ExitCode)"
            return 1
        }
    } else {
        Write-Output "Skipping $ProgramName installation as it is already installed."
        return 0
    }
}

# Function to install .NET Framework 4.8
function Install-DotNet48 {
    param (
        [string]$InstallerPath,
        [string]$InstallerArgs
    )

    if (-not (Is-DotNet48Installed)) {
        Write-Output "Installing .NET Framework 4.8..."
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $InstallerArgs -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Output ".NET Framework 4.8 installed successfully."
            return 0
        } else {
            Write-Output "Failed to install .NET Framework 4.8. Exit Code: $($process.ExitCode)"
            return 1
        }
    } else {
        Write-Output "Skipping .NET Framework 4.8 installation as it is already installed."
        return 0
    }
}

# Define the list of programs to install with paths and arguments
$prereqs = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Path = '.\1-VC++2013\12.0.40664.0\VC2013-Install.cmd';
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2019 Redistributable';
        Path = '.\2-VC++2015\14.38.33135.0\InstallVC.cmd';
    }
)

# Define the .NET Framework 4.8 installer
$dotNetInstaller = @{
    Path = '.\3-.Net 4.8\.Net Framework 4.8\load_netframework_64.cmd';
}

# Loop through and install each Visual C++ Redistributable
foreach ($prereq in $prereqs) {
    $result = Install-Program -ProgramName $prereq.Name -InstallerPath $prereq.Path -InstallerArgs $prereq.Args
    if (-not $result) {
        Write-Output "Stopping further installations due to failure in installing $($prereq.Name)."
        exit 1
    }else{
        Write-Output "$($Prereq.name) Installed correctly, returning code 0"
        return 0
    }
}

# Install .NET Framework 4.8
$dotNetResult = Install-DotNet48 -InstallerPath $dotNetInstaller.Path
if (-not $dotNetResult) {
    Write-Output "Stopping further installations due to failure in installing .NET Framework 4.8."
    exit 1
}else{
    Write-Output "$($Prereq.name) Installed correctly, returning code 0"
    return 0
}

# Uninstall Validation Client

# Install SAP .Net Connector

# Install SAP SCE 7.5

# Install SAP Validation Client

Write-Output "All programs installed successfully."