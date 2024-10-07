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
    foreach ($program in $ProgramList.value) {
        $found = $False

        # Check each registry path for the program
        foreach ($path in $registryPaths) {
            $keys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
            foreach ($key in $keys) {
                $displayName = (Get-ItemProperty -Path $key.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName

                if ($displayName -like "*$($program.Name)*") {
                    Write-Output "$($program.Name) is installed. Updating array value to skip install. <Check-InitialisProgramInstalled>"
                    $program.Installed = $True
                    $found = $True
                    break
                }
            }
            if ($found) { break }  # Stop searching if program is found
        }
        
        if (-not $found) {
            Write-Output "$($program.Name) is not installed. Will attempt to install. <Check-InitialisProgramInstalled>"
        }
    }
    Write-output "Checked all Programs, Moving on."
    $ProgramList.value
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
                Write-Output "$ProgramName is already installed. <Is-ProgramInstalled>"
                return 0
            }else {
                Write-Output "$ProgramName is not installed, attempting to install now. <Is-ProgramInstalled>"
                
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
        Write-Output ".NET Framework 4.8 is already installed. <Is-DotNet48Installed>"
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
            Write-Output "$ProgramName installed successfully. <Install-Program>"

            # Update the "Installed" flag in the $ProgramList array
            foreach ($program in $ProgramList.Value) {
                if ($program.Name -eq $ProgramName) {
                    $program.Installed = $True
                    Write-Output "$ProgramName installation status updated in the list. <Install-Program>"
                }
            }
            return $true
        } else {
            Write-Output "Failed to install $ProgramName. Exit Code: $($process.ExitCode) <Install-Program>"
            return $false
        }
    } else {
        Write-Output "Skipping $ProgramName installation as it is already installed. <Install-Program>"
        return $true
    }
}

# Function to check for .NET Framework 4.8 installation
function Is-DotNet48Installed {
    $regKey = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $release = (Get-ItemProperty -Path $regKey -ErrorAction SilentlyContinue).Release
    if ($release -ge 533320) {
        Write-Output ".NET Framework 4.8 is already installed. <Is-DotNet48Installed>"
        return $true
    }
    return $false
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
            Write-Output ".NET Framework 4.8 installed successfully. <Install-DotNet48>"
                        # Update the "Installed" flag in the $ProgramList array
            foreach ($program in $ProgramList.Value) {
                if ($program.Name -eq $ProgramName) {
                    $program.Installed = $True
                    Write-Output "$ProgramName installation status updated in the list."
                }
            }

        } else {
            Write-Output "Failed to install .NET Framework 4.8. Exit Code: $($process.ExitCode) <Install-DotNet48>"
            return 1
        }
    } else {
        Write-Output "Skipping .NET Framework 4.8 installation as it is already installed. <Install-DotNet48>"

    }
}

# Start logging the transcript
Start-Transcript -Path "$env:ProgramData\TurnerLogs\SAP_Validation_Client_Transcript.txt"

# List of programs to check installation status
$ProgramList = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Installed = $False;
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2022 Redistributable';
        Installed = $False;
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2022 Redistributable';
        Installed = $False;
    },
    @{
        Name = 'Microsoft .NET Runtime';
        Installed = $False;
    },
    @{
        Name = 'SAP .Net Connector 3.0 for .NET 4.0 on x86';
        Installed = $False;
    },
    @{
        Name = 'Validation for SAP Solutions CE 23.2';
        Installed = $False;
    },
    @{
        Name = 'SCE for SAP Solutions 22.2 Patch 37';
        Installed = $False;
    }
)

# Check if the programs are already installed
Check-InitialIsProgramInstalled -ProgramList ([ref]$ProgramList)
"Check Initial Program Installed is done Moving on To Microsoft VC"
# List of programs with installation paths
$MicrosoftVC = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Path = '.\1-VC++2013\12.0.40664.0\VC2013-Install.cmd';
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2022 Redistributable';
        Path = '.\2-VC++2015\14.38.33135.0\InstallVC.cmd';
    }
)

# .NET Framework 4.8 installer
$dotNetInstaller = @{
    Name = 'Microsoft .NET Runtime';
    Path = '.\3-.Net 4.8\.Net Framework 4.8\load_netframework_64.cmd';
}

# Uninstall Validation Client Path - Not being validated
$UninstallValClient = @{
    Name = 'Uninstall Validation Client';
    Path = '.\4-Uninstall Validation Client\Uninstall\SAP_Validation_Client_Prereq_Removal.cmd';
}
# SAP .NET Connector Path
$sapnetConnector = @{
    Name = 'SAP .NET Connector';
    Path = '.\5-SAP .Net Connector\Connector\install-sapconnector.cmd';
}

#SAP Validation Client Path
$sapValidationClient = @{
    Name = 'SAP Validation Client';
    Path = ".\6-SAP Validation Client\Validation Client\install-sapvalidation232.cmd"
}

#SAP SCE Path
$sapSCE = @{
    Name = 'SAP SCE';
    Path = ".\7-SAP SCE 7.5\SCE\install-sapvalidationsce.cmd"
}

# Loop through and install each Visual C++ Redistributable if needed
foreach ($VC in $MicrosoftVC) {
    $program = $ProgramList | Where-Object {$_.Name -eq $VC.Name}
    if (-not $Program.Installed) {
        $result = Install-Program -ProgramName $VC.Name -InstallerPath $VC.Path -ProgramList ([ref]$ProgramList)
        if (-not $result) {
            Write-Output "Stopping further installations due to failure in installing $($VC.Name)."

        }
    }else{
        Write-output "$($VC.Name) is installed, skipping install."

    }
}


# Install .NET Framework 4.8 if needed
$dotNetResult = Install-DotNet48 -InstallerPath $dotNetInstaller.Path 
if (-not $dotNetResult) {
    Write-Output "Stopping further installations due to failure in installing .NET Framework 4.8."
    return 1
}
else{
    Write-Output "$($dotNetInstaller.name) Installed correctly, returning code 0. <dotNetResult>"

}

# Uninstall Validation Client
$ValClientResult = Install-Program -ProgramName $UninstallValClient.Name -InstallerPath $UninstallValClient.Path -ProgramList ([ref]$ProgramList)

    if(-not $result){
        Write-Output "Stopping further installations due to failure in uninstalling $($UninstallValClient.Name)"
        return 1
    }
    else{
        Write-Output "$($UninstallValClient.Name) Installed Correctly, returning code 0."

    }

# Install SAP .Net Connector
$sapnetconnectorResult = Install-Program -ProgramName $sapnetConnector.Name -InstallerPath $sapnetConnector.Path -ProgramList ([ref]$ProgramList)

    if(-not $result){
        Write-Output "Stopping further installations due to failure in uninstalling $($sapnetConnector.Name)"
        return 1
    }
    else{
        Write-Output "$($sapnetConnector.Name) Installed Correctly, returning code 0."
    }

# Install SAP Validation Client
$sapValidationClientResult = Install-Program -ProgramName $sapValidationClient.Name -InstallerPath $sapValidationClient.Path -ProgramList ([ref]$ProgramList)

    if(-not $result){
        Write-Output "Stopping further installations due to failure in uninstalling $($sapValidationClient.Name)"
        return 1
    }
    else{
        Write-Output "$($sapValidationClient.Name) Installed Correctly, returning code 0."
    }

# Install SAP SCE 7.5
$sapsceResult = Install-Program -ProgramName $sapSCE.Name -InstallerPath $sapSCE.Path -ProgramList ([ref]$ProgramList)

    if(-not $result){
        Write-Output "Stopping further installations due to failure in uninstalling $($sapSCE.Name)"
        return 1
    }
    else{
        Write-Output "$($sapSCE.Name) Installed Correctly, returning code 0."
    }

$Success = $True
$NotInstalled = @()

foreach ($Program in $ProgramList) {
    if ($Program.Installed -ne $True) {
        $NotInstalled += $Program.Name
        $Success = $False
    }
}

if (-not $Success) {
    Write-Output "The following programs are not installed:"
    $NotInstalled | ForEach-Object { Write-Output $_ }
    return 1
} else {
    Write-Output "All programs are installed. Check succeeded."
    return 0
}

# Stop logging the transcript
Stop-Transcript