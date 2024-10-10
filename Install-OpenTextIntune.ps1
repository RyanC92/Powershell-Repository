#Install Open Text validation client and dependencies.

$TurnerFolders = @(
    @{
        Name = "TurnerDetection"
        Path = "$env:programdata\TurnerDetection"
    },
    @{
        Name = "TurnerLogs"
        Path = "$env:programdata\TurnerLogs"
    }
)

Foreach ($Folder in $TurnerFolders){
    $PathTest = test-path -Path $Folder.Path
    if(-not $PathTest){
        mkdir "$($env:programdata)\$($Folder.name)"
    }
}

# Start logging the transcript
Start-Transcript -Path "$env:ProgramData\TurnerLogs\SAP_Validation_Client_Transcript.txt"

# List of programs to check installation status, validation criteria and installer paths

$ProgramsToInstall = @(
    @{
        Name = 'Microsoft Visual C++ 2013 Redistributable';
        Path = '.\1-VC++2013\12.0.40664.0\VC2013-Install.cmd';
        Args = '';
        ValidationCriteria = "$env:programdata\TurnerDetection\VC2013-12.0.40664.0.txt";
    },
    @{
        Name = 'Microsoft Visual C++ 2015-2022 Redistributable';
        Path = '.\2-VC++2015\14.38.33135.0\InstallVC.cmd';
        Args = '';        
        ValidationCriteria = "$env:programdata\TurnerDetection\VC2015-2022-14.38.33135.0.txt";
    },
    @{
        Name = 'Microsoft .NET Runtime';
        Path = '.\3-.Net 4.8\.Net Framework 4.8\load_netframework_64.cmd';   
        ValidationCriteria = "$env:programdata\TurnerDetection\.NET-4.8.3928.0.txt"; 
    },
        @{
        Name = 'Uninstall Validation Client';
        Path = '.\4-Uninstall Validation Client\Uninstall\SAP_Validation_Client_Prereq_Removal.cmd';
        ValidationCriteria = "Skip"; 
    },
    @{
        Name = 'SAP .NET Connector 3.0 for .NET 4.0 on x86';
        Path = '.\5-SAP .Net Connector\Connector\install-sapconnector.cmd';
        ValidationCriteria = "$env:programdata\TurnerDetection\SAP_.Net_Connector_NET40_x86.txt"; 
    },
    @{
        Name = 'Validation for SAP Solutions CE 23.2';
        Path = ".\6-SAP Validation Client\Validation Client\install-sapvalidation232.cmd";
        ValidationCriteria = "$env:programdata\TurnerDetection\Validation_For_SAP_Solutions_CE_232.txt"; 
    },
    @{
        Name = 'SCE for SAP Solutions 22.2 Patch 37';
        Path = ".\7-SAP SCE 7.5\SCE\install-sapvalidationsce.cmd";
        ValidationCriteria = "$env:programdata\TurnerDetection\SCE_for_SAP_Solutions.txt";       
    }
)


#install programs 
# 1. VC++ 2013
# 2. VC++ 2015-2022
# 3. .NET Runtime
# 4. Uninstall Validation Client
# 5. SAP .NET Connector 3.0 for .NET 4.0 on
# 6. Validation for SAP Solutions CE 23.2
# 7. SCE for SAP Solutions 22.2 Patch 37

Foreach ($Program in $ProgramsToInstall){
    
    if($program.ValidationPath -ne "$Null"){
        $test = test-path $Program.ValidationPath
    }

    if($test){
        Write-output "Based on Test Path Validation the txt doc exists, skipping the install for $($Program.Name)"
    }else{
        try{
            Write-Output "Attempting Install of $($Program.Name)"
            Start-Process $Program.Path -Wait -Passthru -ErrorAction Stop
            Write-Output "$($Program.Name) installed Successfully - RC = 0"
            
            #Check validation criteria post install
            $ValTest = test-path -Path $Program.ValidationCriteria
            if($ValTest){
                Write-Output "Validation of $($Program.Name) successful - RC = 0"
            }else{
                Write-Output "Validation of $($Program.Name) was Unsuccessful - RC = 1"
                Return 1
            }
        }
        catch{
            Write-Output "Install of $($Program.Name) failed."
            return 1
        }
    }
}

Stop-Transcript