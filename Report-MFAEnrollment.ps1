import-module importexcel
import-module activedirectory

$OUS = @(
    #'OU=Users,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org'
    #'OU=Users,OU=Albany,OU=North East,OU=Offices,DC=tcco,DC=org'
    #'OU=Users,OU=Buffalo,OU=North East,OU=Offices,DC=tcco,DC=org'
    #'OU=Users,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org'
    #'OU=Users,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org'
    #'OU=Users,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=TSIB,OU=North East,OU=Offices,DC=tcco,DC=org'
    )

#Establish variables and arrays
$OURegex = [String]::Join('|',$OUS)
$mfanew = @()
$usernew= @()
$mfaArray= @()
$userIn = @()
$userIn1 = @()
$userEx = @()

#Get List of group members for MDM
#$mfa = get-adgroupmember -Identity TUR.ALL.MFA.USERS
Write-host "Getting TUR.ALL.MFA.USERS Group`n" -ForegroundColor Green
$mfa = get-adgroup -Identity TUR.ALL.MFA.USERS -Properties Member | Select-Object -ExpandProperty Member | Get-ADUser -Property Name, Displayname

#Foreach user object in $MDM, check to see if their distinguished name has one of the OUs, If $True run a Get-ADuser search and save to $mdmNew
"Processing the MFA User Group to regex the group membership"
Foreach($m in $mfa){
    if($m.DistinguishedName -match $OURegex){
        "Running Regex on $($M.Displayname)"
        $mfaArray = get-aduser -identity $m.samaccountname -properties displayname | select Displayname
        $mfaNew += $mfaArray
        $mFaArray
    }else{

    }
}


#Foreach OU from $OUs list to get the comparison array then compare it against mdmNew and export to excel PANJMDMUsers for two categories, completed and not enrolled.
ForEach($OU in $OUs){
    Write-host "Running for $OU" -ForegroundColor Green
    $Users = Get-aduser -SearchBase $OU -Filter * -properties Displayname | Select displayName
    $userIn = Compare-Object -DifferenceObject $users.displayname -ReferenceObject $mfaNew.displayname -IncludeEqual -ExcludeDifferent
    $userIn1 += $userIn
    $userEx = Compare-Object -DifferenceObject $users.displayname -ReferenceObject $mfaNew.displayname
    $userEx | export-excel  -WorksheetName "Not Enrolled" -path C:\temp\PANJMFAUsers-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx -Append -Autosize -Title "Not yet Enrolled" -Autofilter

}

$userIn1 | export-excel  -Worksheetname "Enrolled" -path C:\Temp\PANJMFAUsers-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx -Append -Autosize -Title "Enrolled" -Autofilter
