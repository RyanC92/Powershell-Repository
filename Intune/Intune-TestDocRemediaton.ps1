$files = @(
    "testdoc.txt"
)

$Path = "C:\Temp\"

$badcount = 0
foreach ($file in $files){
    if (Test-Path "$Path\$file"){
        Write-host ("{0} was found" -f $file)

    }
    else {
        Write-host ("{0} was found" -f $file)
        $badcount++
    }
}

IF ($badcount -gt 0){
    Write-host ("Not all files were not found")
    exit 1
}
else {
    Write-host ("All files were found")
    exit 0
}