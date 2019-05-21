#Try Catch Finally Test

$PrintCSV = Import-csv C:\CSV\PrinterExport.csv

$Server = "NEPPRDPRINT1"

try {
   ForEach($Printer in $PrintCSV){

        Get-Printer -ComputerName $Server -Name $Printer.Name  -ErrorAction SilentlyContinue
        #$Error | Export-csv C:\csv\Errors.csv -append 
   }
}

catch {
    
    "Printer Not Available Logging: $_" | Add-Content C:\CSV\ErrorLog.txt
}

