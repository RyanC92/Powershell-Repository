$RemServer = "USNJDC003.excelsior.local"
$s = new-pssession -computer $RemServer
Invoke-command -session $s -Script {Import-Module ActiveDirectory}
Import-PSSession -session $s -modulE activedirectory -prefix Rem