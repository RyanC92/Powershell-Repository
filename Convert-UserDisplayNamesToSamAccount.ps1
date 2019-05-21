#This is for when you get a csv with displaynames vs the direct samaccountname.
#It will search the user based on the displayname and spit out the Samaccountname which can be used as an identity for Add-AdGroupmember

$users = Import-CSV C:\CSV\AplicareEmail.CSV 

$adGroup = read-host "Enter AD Group name"

ForEach ($user in $users) {

    $samacc = Get-Aduser -Filter { displayName -like $($user.displayname)} | select samaccountname #| export-csv C:\CSV\AplicareEmailSamAccountName.csv -append -NoTypeInformation

        ForEach ($samaccs in $samacc) {
            Write-host "$($Samaccs.name) - $($Samaccs.Samaccountname) has been added to $adGroup"
            Add-ADGroupMember -Identity $adGroup -Members $($Samaccs.Samaccountname)
            
        } 
        

}


