import-module importexcel

$OUS = @(
    'OU=Users,OU=New Jersey,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Albany,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Buffalo,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Philadelphia,OU=North Central,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Pittsburgh,OU=North Central,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=Mahwah,OU=North East,OU=Offices,DC=tcco,DC=org'
    'OU=Users,OU=TSIB,OU=North East,OU=Offices,DC=tcco,DC=org'
    )

#Establish variables and arrays
$OURegex = [String]::Join('|',$OUS)
$mdmnew = @()
$usernew= @()

#Get List of group members for MDM
$mdm = get-adgroupmember -Identity TUR.ALL.MDM.USERS

#Foreach user object in $MDM, check to see if their distinguished name has one of the OUs, If $True run a Get-ADuser search and save to $mdmNew
Foreach($m in $mdm){
    if($m.DistinguishedName -match $OURegex){
        $mdmArray = get-aduser -identity $m.samaccountname -properties displayname | select Displayname
        $mdmNew += $mdmArray
        $mdmArray
    }else{

    }
}


#Foreach OU from $OUs list to get the comparison array then compare it against mdmNew and export to excel PANJMDMUsers for two categories, completed and not enrolled.
ForEach($OU in $OUs){
    "Running for $OU"
    $Users = Get-aduser -SearchBase $OU -Filter * -properties Displayname | Select displayName
    $userIn1 = Compare-Object -DifferenceObject $users.displayname -ReferenceObject $mdmNew.displayname -IncludeEqual -ExcludeDifferent
    $userIn += $userIn1
    $userEx = Compare-Object -DifferenceObject $users.displayname -ReferenceObject $mdmNew.displayname
    $userEx | export-excel  -WorksheetName "Not Enrolled" -path C:\temp\PANJMDMUsers-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx -Append -Autosize -Title "Not yet Enrolled" -Autofilter

}

$userIn | export-excel  -Worksheetname "Enrolled" -path C:\Temp\PANJMDMUsers-$([DateTime]::Now.ToSTring("MM-dd-yyyy")).xlsx -Append -Autosize -Title "Enrolled" -Autofilter
