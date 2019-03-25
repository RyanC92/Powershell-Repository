$Users = Import-csv "C:\CSV\Medline Email Matches.csv"

Pause
 
Foreach($User in $Users) {

    Set-SPuser -Identity $_.Identity -Email $_.Email -Web Http://Intranet

    }
