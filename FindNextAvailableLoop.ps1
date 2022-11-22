
$CompName = Get-adcomputer -filter {Name -like "NJOLAP*"} | Select Name
$i = 1


ForEach($PCName in $CompName){
    "Searching for a free hostname $($PCName.Name)"
    
    while(($Match = "NJOLAP$('{0:d4}' -f $i)") -eq $($PCName.Name)){
        "$Match is True, Keep Looking"
        $i++
    }
        "$Match is False, We can use this!"
        $i++

}