#Set-Execution
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

$ExecutionPolicyCheck = Get-ExecutionPolicy

if($ExecutionPolicyCheck -eq "Bypass")
{
    Exit 0
}
else
{
    Exit 1
}