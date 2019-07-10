$Comps = Import-csv "\\usnjfs001\shared\Ryan Curran\Scripts_Icons\Line comps.csv"

ForEach($Comp in $Comps){
    Try{
        Write-host "Removing Vision System Assistance From $($Comp.name)"
        Remove-item -path "\\$($Comp.name)\C$\Users\Public\Desktop\Vision System Assistance.lnk" -ErrorAction Stop
    }Catch{
        "$($Comp.name) Shortcut doesnt exist"
    }

    Try{
        Write-host "Removing Vision System Assistance From $($Comp.name)"
        Remove-item -path "\\$($Comp.name)\C$\Users\Public\Desktop\Vision System Assistance.lnk" -ErrorAction Stop
    }Catch{
        "$($Comp.name) Shortcut doesnt exist"
    }

    Try{
        "Copying Vision System Assistance Shortcut to $($Comp.name)"
        xcopy "\\usnjfs001\shared\Ryan Curran\Scripts_Icons\medline icons\Vision System Assistance.lnk" "\\$($Comp.name)\C$\Users\Public\Desktop\"
    }Catch{
        "$($Comp.Name) is Offline"
    }

}

pause