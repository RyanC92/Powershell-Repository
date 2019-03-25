
$site = Get-SPSite https://newleafflorida-admin.sharepoint.com
$web = $site.OpenWeb()
$groups = $web.sitegroups
 
foreach ($grp in $groups) {
    "Group: " + $grp.name;
    $groupName = $grp.name
    write-host "Group: " $groupName   -foregroundcolor green
    foreach ($user in $grp.users) {
            "User: " + $user.name
            write-host "User " $user.UserLogin   -foregroundcolor red
    }
}