function Show-Menu
{
    param (

        [string]$Title = "My Menu"
    )
    cls
    Write-Host "================ $Title ================"

     Write-Host "1: Press '1' for this option." 
     Write-Host "2: Press '2' for this option." 
     Write-Host "3: Press '3' for this option." 
     Write-Host "Q: Press 'Q' to quit." 
}

do
{
    Show-Menu
    $input = Read-host "Please Make a Selection"
    switch($Input){
        '1'{
        cls
        'You Chose Option #1'
        }'2'{
        cls
        'You Chose Option #2'
        }'3'{
        cls
        'You Chose Option #3'
        }'q'{
            return
        }

    }
    pause
}
until ($input -eq 'q')
