# Function to check if a specific program is installed by searching the registry

function Check-InitialIsProgramInstalled {
    param (
        [ref]$ProgramList
    )

    # Define registry paths for installed programs
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    # Loop through each program in the list
    foreach ($program in $ProgramList.Value) {
        $found = $False

        # Check each registry path for the program
        foreach ($path in $registryPaths) {
            $keys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
            foreach ($key in $keys) {
                $displayName = (Get-ItemProperty -Path $key.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName

                if ($displayName -like "*$($program.Name)*") {
                    Write-Output "$($program.Name) is installed. Updating array value to skip install."
                    $program.Installed = $True
                    $found = $True
                    break
                }
            }
            if ($found) { break }  # Stop searching if program is found
        }
        
        if (-not $found) {
            Write-Output "$($program.Name) is not installed. Will attempt to install."
        }
    }
}

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
            }else {
                Write-Output "$ProgramName is not installed, attempting to install now."
                
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
        [string]$InstallerPath,
        [ref]$ProgramList
    )

    # Check if the program is already installed
    if (-not (Is-ProgramInstalled -ProgramName $ProgramName)) {
        Write-Output "Installing $ProgramName..."
        $process = Start-Process -FilePath $InstallerPath -Wait -PassThru

        # Check if installation was successful
        if ($process.ExitCode -eq 0) {
            Write-Output "$ProgramName installed successfully."

            # Update the "Installed" flag in the $ProgramList array
            foreach ($program in $ProgramList.Value) {
                if ($program.Name -eq $ProgramName) {
                    $program.Installed = $True
                    Write-Output "$ProgramName installation status updated in the list."
                }
            }
            return $true
        } else {
            Write-Output "Failed to install $ProgramName. Exit Code: $($process.ExitCode)"
            return $false
        }
    } else {
        Write-Output "Skipping $ProgramName installation as it is already installed."
        return $true
    }
}

# Function to install .NET Framework 4.8
function Install-DotNet48 {
    param (
        [string]$InstallerPath
    )

    if (-not (Is-DotNet48Installed)) {
        Write-Output "Installing .NET Framework 4.8..."
        $process = Start-Process -FilePath $InstallerPath -Wait -PassThru
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

Start-Transcript -OutputDirectory "$env:ProgramData\TurnerLogs\SAP_Validation_Client_Transcript.txt"

$ProgramList = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Installed = $False;
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2019 Redistributable';
        Installed = $False;
    },
    @{
        Name = 'Microsoft .NET Runtime';
        Installed = $False;
    },
    @{
        Name = #SAP .Net Connector;
        Installed = $False;
    },
    @{
        Name = #SAP SCE 7.5;
        Installed = $False;
    },
    @{
        Name = #SAP Validation Client
        Installed = $False;
    }
)

Check-InitialIsProgramInstalled -ProgramList ([ref]$ProgramList)


# List of programs to install with paths, validation paths and validation file names
$MicrosoftVC = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Path = '.\1-VC++2013\12.0.40664.0\VC2013-Install.cmd';
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2019 Redistributable';
        Path = '.\2-VC++2015\14.38.33135.0\InstallVC.cmd';
    }
)

# .NET Framework 4.8 installer - Not being validated
$dotNetInstaller = @{
    Name = 'Microsoft .NET Runtime';
    Path = '.\3-.Net 4.8\.Net Framework 4.8\load_netframework_64.cmd';
}

# Uninstall Validation Client Path - Not being validated
$UninstallValClient = @{
    Name = 'Uninstall Validation Client';
    Path = '.\4-Uninstall Validation Client\Uninstall\SAP_Validation_Client_Prereq_Removal.cmd';
}

# Uninstall Validation Client Path - Not being validated
$sapnetConnector = @{
    Name = 'SAP .NET Connector';
    Path = '.\5-SAP .Net Connector\Connector\install-sapconnector.cmd';
}

# Loop through and install each Visual C++ Redistributable
foreach ($VC in $MicrosoftVC) {
    
    $result = Install-Program -ProgramName $VC.Name -InstallerPath $VC.Path

    if (-not $result){
        Write-Output "Stopping further installations due to failure in installing $($VC.Name)."
        exit 1
    }
    else{
        Write-Output "$($VC.name) Installed correctly, returning code 0."
        return 0
    }
}

# Install .NET Framework 4.8
$dotNetResult = Install-DotNet48 -InstallerPath $dotNetInstaller.Path
if (-not $dotNetResult) {
    Write-Output "Stopping further installations due to failure in installing .NET Framework 4.8."
    exit 1
}
else{
    Write-Output "$($VC.name) Installed correctly, returning code 0."
    return 0
}

# Uninstall Validation Client
$ValCLientResult = Install-Program -ProgramName $UninstallValClient.Name -InstallerPath $UninstallValClient.Path

    if(-not $result){
        Write-Output "Stopping further installations due to failure in uninstalling $($UninstallValClient.Name)"
        exit 1
    }
    else{
        Write-Output "$($UninstallValClient.Name) Installed Correctly, returning code 0."
        return 0
    }

# Install SAP .Net Connector
$sapnetconnectorResult = Install-Program -ProgramName $sapnetConnector.Name -InstallerPath $sapnetConnector.Path

    if(-not $result){
        Write-Output "Stopping further installations due to failure in uninstalling $($sapnetConnector.Name)"
        exit 1
    }
    else{
        Write-Output "$($sapnetConnector.Name) Installed Correctly, returning code 0."
        return 0
    }
# Install SAP SCE 7.5

# Install SAP Validation Client

Write-Output "All programs installed successfully."
Stop-Transcript