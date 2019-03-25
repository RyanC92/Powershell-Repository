
Get-ADGroup -Filter * -PipelineVariable Group | Get-ADGroupMember -PipelineVariable Member | ForEach-Object {
    
    New-Object psobject -Property @{
        Group = $group.Name

        "Group DN" = $Group.Name
        "Group SamAccountName" = $Group.SamAccountName
        "Member DN" = $Member.DistinguishedName
        "Member Name" = $Member.Name
        "Member SamAccountName" = $Member.SamAccountName
        }
} #| Export-CSV C:\Powershell\Export1.csv -Append -NoTypeInformation

<#
$ADgroups = Get-ADgroup -Filter *

foreach ($ADGroup in $ADgroups) {

    Get-AdgroupMember -Identity $Adgroup.DistinguishedName | Select * | Export-CSV C:\Powershell\Export.csv -Append

    }

#>