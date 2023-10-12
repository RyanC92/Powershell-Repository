# First, let's encode the external file as Base64. Do this once.
$Items = Get-ChildItem

Foreach($item in $items){
    
    $Content = Get-Content -Path "$($item.DirectoryName)\$($Item.name)" -Encoding Byte
    $Base64 = [Convert]::ToBase64String($Content)
    $Base64 | Out-File "$($pwd.path)\$($item.name).txt"
    

} 




