$ADgroups = Get-ADgroup -Filter *

ForEach ($AdGroup in $ADgroups) {

    Get-AdgroupMember -Identity $Adgroup.DistinguishedName

}
