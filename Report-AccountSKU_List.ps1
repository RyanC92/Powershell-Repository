$i = 0

Get-MsolAccountSku

do
{

    Write-Host "$i, $($SKU[$i].AccountSkuId)"
    $i++
}
    
    While($i -le $Sku.count-1)
    
        [int]$userChoice = Read-Host "Please select the license to export."

        ForEach($User in $Users) 

{

    $users = Get-Msoluser | Where { $_.Licenses.accountskuid -like "*$($sku[$i].AccountSkuID)*"}

}