$Path = $Env:programdata
 
$RC1 = Test-Path -Path $Path'%programdata%\TurnerDetection\VC2010-10.0.40219.325.txt' -PathType Leaf
$RC2 = Test-Path -Path $Path'%programdata%\TurnerDetection\VC2012-11.0.61030.0.txt' -PathType Leaf
$RC3 = Test-Path -Path $Path'%programdata%\TurnerDetection\VC2013-12.0.40664.0.txt' -PathType Leaf
 
If ( $RC1 -and $RC2 -and $RC3 ) {
   Write-Output "Detection Successful"
   EXIT 0
} ELSE {
   Write-Output "Detection Failed: RC1 = $($RC1), RC2 = $($RC2), RC3 = $($RC3)"
   EXIT 1