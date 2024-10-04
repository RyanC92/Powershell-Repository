#Write this to create C:\Temp and other folders C:\ProgramData\TurnerLogs C:\ProgramData\TurnerDetection

$Path = "C:\Temp\"

$badcount = 0
foreach ($file in $files){
    if (Test-Path "$Path"){
        Write-output ("{0} was found" -f $file)

    }
    else {
        Write-output ("{0} was found" -f $file)
        $badcount++
    }
}

IF ($badcount -gt 0){
    Write-output ("Folder not found, creating $Path.")

    New-Item -Path "C:\Path\To\Your\Folder" -ItemType Directory

    exit 1
}
else {
    Write-output ("Folder was found")
    exit 0
}