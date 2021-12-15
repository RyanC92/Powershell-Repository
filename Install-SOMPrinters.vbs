Option Explicit
Dim netPrinter, UNCpath, UNCpath1, UNCpath2
UNCpath = "\\SOMPRNT2\som.bus.main.laniercolor8003"
UNCpath1 = "\\somprnt2\SOM.BUS.MAIN.RICOH9003"
UNCpath2 = "\\somprnt2\SOM.BUS.MAIN.PLOT.HP3500"
Set netPrinter = CreateObject("WScript.Network")
netPrinter.AddWindowsPrinterConnection UNCpath
WScript.Echo "Your printer is mapped from : " & UNCpath
netPrinter.AddWindowsPrinterConnection UNCpath1
WScript.Echo "Your printer is mapped from : " & UNCpath1
netPrinter.AddWindowsPrinterConnection UNCpath2
WScript.Echo "Your printer is mapped from : " & UNCpath2

WScript.Quit
