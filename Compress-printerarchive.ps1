$path = 'C:\Temp\Print Drivers\'

$chitem = Get-childitem $path | select name, Fullname

Foreach ($Printer in $chitem){
    "Compressing $($Printer.Name) to C:\TCCODrivers\$($Printer.Name).zip" 
    Compress-Archive $printer.Fullname -DestinationPath "C:\TCCODrivers\$($Printer.Name)" -CompressionLevel Optimal -Force

}