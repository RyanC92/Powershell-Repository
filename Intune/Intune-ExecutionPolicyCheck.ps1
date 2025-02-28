#Check Execution policy
$ExecutionPolicyCheck = Get-ExecutionPolicy

if ($ExecutionPolicyCheck -ne "Bypass") {
    #Remediation Needed
    Exit 1
}else{
    #No Remediation Needed
    Exit 0
}