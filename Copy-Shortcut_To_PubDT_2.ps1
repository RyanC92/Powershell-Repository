$Comps = Import-csv "\\usnjfs001\shared\Ryan Curran\Scripts_Icons\Line comps.csv"

ForEach($Comp in $Comps){

    xcopy "\\usnjfs001\shared\Ryan Curran\Scripts_Icons\medline icons\Machine Breakdown Log.website" "\\$Comp\C$\Users\Public\Desktop\"
}

pause