<#
Printer Management
By: Ryan Curran
3/15/19
#>


Write-host "Below, type the following options to install the printers. All printers are Globally added with the /ga  parameter"
Write-Host "Type Xerox at any time to Skip everything and Install or Uninstall all Xerox Printers"

$Building = Read-Host "Which Building? Type either the number (1. 2. 3. 4. 5. or The building number (1919, 1923, 1930 or 1933) or Xerox `n 
1. 1919 `n
2. 1923 `n
3. 1930 `n
4. 1933 `n
5. Xerox `n
`n 
Choice"

switch ($Building) {
    '1' {    Write-Host "Available Printers: `n
        1. NEPPRINTER12 - Facilities `n
        2. NEPPRINTER101 - Optrel Room `n"
        $Printer = Read-Host "Which Printer Do you want to Install? `n
        `n
        Printer"
    
            switch ($printer) {
                '1'{
                    rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Black & White"
                    rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Color"
                }
                '2'{
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
                    rundll32 printui.dll,PrintUIEntry /ga  /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
                }
            }
    }

    }

    '2' {     Write-Host "Available Printers: `n
        1. NEPPRINTER01 - 1923 Supervisors Area `n
        2. NEPPRINTER10 - Miurel Laguna `n
        3. NEPPRINTER13 - Abraham Montealegre `n
        4. NEPPRINTER22 - AQL Office `n
        5. NEPPRINTER30 - Post Sterilization `n
        6. NEPPRINTER100 - Clean Rooms `n
        7. All Printers"
        $Printer = Read-Host "Which Printer Do you want to Install? `n
        `n
        Printer"

            switch ($Printer) {
                '1'{
                    rundll32 printui.dll,PrintUIEntry /in /ga /y /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Black & White"
                    rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Color"
                }
                '2'{ 
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER10 - Black & White"
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER10 - Color"
                }
                '3'{
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER13 - Abraham Montealegre - Black & White"
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"NEPPRINTER13 - Abraham Montealegre - Color"
                }
                '4'{
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER22 - AQL Office - Black & White"
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER22 - AQL Office - Color"
                }
                '5'{
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER22 - AQL Office - Black & White"
                    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER22 - AQL Office - Color"  

                }
            }

    }  
} 

<#
if ($Building -eq "1" -or "1919"){
    Write-Host "Available Printers: `n
    1. NEPPRINTER12 - Facilities `n
    2. NEPPRINTER101 - Optrel Room `n"
    $Printer = Read-Host "Which Printer Do you want to Install? `n
    `n
    Printer"

    if($Printer -eq "1" -or "NEPPRINTER12" -or "NEPPRINTER12 - Facilities" -or "Facilities"){
        rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Black & White"
        rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Color"
    }elseif($Printer -eq "2" -or "NEPPRINTER101" -or "NEPPRINTER101 - Optrel Room" -or "Optrel Room"){
        rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
        rundll32 printui.dll,PrintUIEntry /ga  /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
    
    }
   
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\Secure Print - Color"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\Secure Print - Black & White"


}elseif($Building -eq "2" -or "1923"){
    Write-Host "Available Printers: `n
    1. NEPPRINTER01 - 1923 Supervisors Area `n
    2. NEPPRINTER10 - Miurel Laguna `n
    3. NEPPRINTER13 - Abraham Montealegre `n
    4. NEPPRINTER22 - AQL Office `n
    5. NEPPRINTER30 - Post Sterilization `n
    6. NEPPRINTER100 - Clean Rooms `n
    7. All Printers"
    $Printer = Read-Host "Which Printer Do you want to Install? `n
    `n
    Printer"
    if($Printer -eq "1" -or "NEPPRINTER01" ){
        rundll32 printui.dll,PrintUIEntry /in /ga /y /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Black & White"
        rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Color"
    }elseif($Printer -eq "2" -or "NEPPRINTER10" ){
        rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER10 - Black & White"
        rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER10 - Color"
    }elseif($Printer -eq "3" -or "NEPPRINTER13"){
        rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER13 - Abraham Montealegre - Black & White"
        rundll32 printui.dll,PrintUIEntry /in /ga /n"NEPPRINTER13 - Abraham Montealegre - Color"
    }elseif($Printer -eq "4" -or "NEPPRINTER22"){
        rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER22 - AQL Office - Black & White"
        rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER22 - AQL Office - Color"
    }elseif($Printer -eq "5" -or "NEPPRINTER30"){


    }
}elseif($Building -eq "Xerox" -or "5"){

    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER04 - 1933 Supervisors Office - Black & White"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER04 - 1933 Supervisors Office - Color"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER02 - 1933 Finance Hallway - Black & White"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER02 - 1933 Finance Hallway - Color"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER03 - 1933 Quality - Color"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER03 - 1933 Quality - Black & White"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER01 - 1923 Supervisors Area - Black & White"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER01 - 1923 Supervisors Area - Color"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
    
    #Secure Print
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\Secure Print - Color"
    rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\Secure Print - Black & White"    

}
#>

rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\Secure Print - Color"
rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\Secure Print - Black & White"






<#function bld1919(){

    $Printer = Read-Host "Which Printer Do you want to Install? `n
    `n
    Printer"

        switch ($printer) {
            '1'{
                rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Black & White"
                rundll32 printui.dll,PrintUIEntry /in /ga /n "\\NEPPRDPRINT1\NEPPRINTER12 - Facilities - Color"
            }
            '2{
                rundll32 printui.dll,PrintUIEntry /in /ga /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
                rundll32 printui.dll,PrintUIEntry /ga  /n"\\NEPPRDPRINT1\NEPPRINTER101 - Optrel Room - Black & White"
            }
        }
}#>