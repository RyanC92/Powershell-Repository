$results = @()
$pattern = "\((.*?)\)"
$users = Get-ADUser  -Properties memberof, displayname, office, Manager -Filter {Enabled -eq $True}
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $match = [regex]::Match($User.DisplayName,$pattern)
    $results += New-Object psObject -Property @{
        'User'=$user.name
        'DisplayName'=$user.DisplayName
        'Office'=$user.office
        'Groups'= $groups
        'Manager'=$user.Manager
        'UserPrincipalname'=$user.UserPrincipalname
        'BU'= $match.Groups[1].Value
    }
}
$results | Where-Object { $_.groups -notmatch 'TUR.ALL.MDM.USERS' -and $_.Manager -ne $null} | Select-Object user, displayname, UserprincipalName, BU,Office | Export-excel "C:\Users\rcurran\Turner Construction\IS Field Staff - PANJ and NYN\Regional Projects\MDM\NonEnrolledMDMUsers.xlsx" -Autosize -Autofilter -WorksheetName "Not Enrolled"




#'BU'=$user.DisplayName.Substring($user.Displayname.IndexOf("(")+1,$User.Displayname.IndexOf(")")-$User.DisplayName.IndexOf("(")-1)