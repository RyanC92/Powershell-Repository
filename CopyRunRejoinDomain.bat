@echo off

xcopy .\rejoindomain.ps1 C:\Temp\

Powershell.exe -executionpolicy remotesigned -file  C:\Temp\rejoindomain.ps1
pause