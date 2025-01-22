#Create txt doc

$Path = "C:\Temp\"

if (Test-Path $Path){
    Write-Host ("{0} was found" -f $Path)
}else{
    Write-Host ("{0} was not found, creating path" -f $Path)
    New-Item -ItemType Directory -Path $Path | Out-Null
}

#Create txt doc
New-item -Path "C:\temp\testdoc.txt" -itemType "file"

exit 1