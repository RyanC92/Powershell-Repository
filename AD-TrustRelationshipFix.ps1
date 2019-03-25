#User input
$Computer = Read-Host "Enter Computer name"
$AdminAccount = Read-Host "Enter local Admin Account"
$SecurePassword = Read-Host "Enter local Admin Password" -AsSecureString

# Create Plain text password object and Credential Object
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminAccount, $SecurePassword

#Enable PS Remoting
#C:\Users\hsheldon\Desktop\Software\PSTools\Psexec.exe \\$Computer -u $AdminAccount -p $UnsecurePassword -h -d powershell.exe "enable-psremoting -force"

# Repair secure Channel
Write-Host "Resetting computer secure channel..."
Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { Test-ComputerSecureChannel -Repair }