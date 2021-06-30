@echo off
REM Copying Files to C:\Temp
xcopy .\Rename-PC.PS1 /y

REM Opening Powershell to run Reg Key as Admin
powershell.exe Start-process powershell -verb runas -argumentlist "C:\temp\Rename-PC.PS1"