$A = 0
$P = Read-host "Enter Initial Principal (Loan Amount)"
$R1= Read-Host "Enter Interest Rate Per Period (Ex: 7.5)"
$R = $R1/12
$N = Read-host "Enter total number of payments or periods (ex: 360 for 30 year)"
$i = 0
$N1 = $N

While ($I -le $N){
    $i++
    
    
    $Principal = ($P*(($R*([Math]::pow((1+$R),$n1)))/([Math]::pow((1+$r),$n1)-1)))
    "Principal: $Principal"
    #$Principal
    "Rate Per Period: $R"
    "Payments Remaining: $N1"
    $N1 -= 1
    
}
$i=0
$G=0
$P=0
$R=0
$N=0
$N1=0 