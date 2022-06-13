# Establish Static Variables
Import-module activedirectory

$PreNew = read-host "Enter new prefix"
$PreOld = read-host "Enter old prefix"
$Cred = Get-Credential
$OldName = "*$($Preold)LAP*"

$Laptops = get-adcomputer -filter {Name -like $OldName} | Select-Object Name

#$lap = read-host "what is the name of the laptop?"


# Next we build the code structure for a foreach loop

Foreach ($laptop in $laptops.name){

    "testing laptop $laptop"
    #run a test connection once, by using the -quiet flag it will return a boolean response of $True or $False

    $testcon = test-connection -Computername $laptop -count 1 -quiet

    IF ($testcon -eq $True){

        Write-host "$Laptop pinged $testcon" -ForegroundColor Green
        
        #we need to get the IP of the laptop to re-query it and verify that the hostname matches the hostname from $laptop
        
        $testcon2 = test-connection -ComputerName $laptop -count 1
        
        Write-host "IP is $($testcon2.ipv4address)" -ForegroundColor Green
        Write-Host "Verifying hostname against original hostname $laptop"
        
        $verify = get-wmiobject -Computername $testcon2.IPv4address -Class Win32_ComputerSystem | Select-Object -ExpandProperty name
        "Hostname from remote computer is $($Verify)"

        IF ($Verify -eq $laptop){

            Write-host "$Verify matches the hostname $laptop, proceeding with renaming" -ForegroundColor Green
            #change the hostname to the new one using .replace 
            $hnNew = $laptop.replace("$PreOld","$PreNew")
            Rename-computer -ComputerName $laptop -NewName $hnNew -Force -DomainCredential $Cred

        }else{
            Write-host "$Laptop failed renaming, exporting" -ForegroundColor Red
            $laptop | Export-csv C:\Temp\FailedRename.csv -Append -NoTypeInformation

        }
    }else {

        Write-host "$Laptop failed the test ping, exporting the hostname" -ForegroundColor Red

        $laptop | Export-csv C:\temp\FailedRename.csv -Append -NoTypeInformation
    }   

}