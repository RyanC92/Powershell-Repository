#Restore for Sharon Rowles

Connect-Pnponline -url  -interactive

$restoredate = ((Get-Date).Date.AddDays(-0))

$RecycleBinitemsNL = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*srowles@tcco.com*")} | select -last 4800
$i = 0
$loop = 1
While($($RecycleBinitemsNL.count) -notlike "0"){

    Foreach ($ID in $RecycleBinitemsNL){
        
        Write-Progress -Activity "Restoring Files" -Status "Updating: $i of $($RecycleBinitemsNL.count) of Loop $Loop"
        "Restoring $($ID.Title)"
        
        Try{ 
            Restore-PnPRecycleBinItem -Identity "$($ID.ID)"-force
        $i++ 
        }Catch{
            Write-host "$($ID.Title) Errored Out. This could be because the file already exists and will not overwrite." -ForegroundColor Red -BackgroundColor Black
        }
    }

        $RecycleBinitemsNL = Get-PnPRecycleBinItem | ? {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -like "*srowles@tcco.com*")} | select -last 4800
        $i=0
        $loop++ 
}
