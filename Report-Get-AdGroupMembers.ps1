$ADgroups = Get-ADgroup -Filter {Name -like "RG-Excelsior*"}

ForEach ($AdGroup in $ADgroups) {

    Get-AdgroupMember -Identity $Adgroup.DistinguishedName | Select Name, SamAccountName, @{Name="Security Group"; Expression = {$AdGroup.name}} | Export-csv C:\CSV\ADGroupMembers-RG-$((Get-Date).ToString("MM-dd-yy_hh_mm")).CSV -append -notypeinformation

}
