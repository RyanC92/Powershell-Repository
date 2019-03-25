Get-ADgroup -Filter * -PipelineVariable group | 
Get-AdgroupMember -PipelineVariable member | ForEach-Object {
    New-Object psobject -Property @{
        Group = $group.Name
        "Group DN" = $group.Distinguishedname
        "Group SamAccountName" = $group.SamAccountName
        "Member DN" = $member.DistinguishedName
        "Member Name" = $member.Name
        "Member SamAccountName" = $member.SamAccountName
    } | Export-CSV C:\CSV\Test.csv -Append -NoTypeInformation
} 