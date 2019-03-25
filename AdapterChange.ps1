<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Change Adapter
.SYNOPSIS
    Choose an adapter, change the IP for the line
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "Form"
$Form.TopMost                    = $false

$AdapterList                     = New-Object system.Windows.Forms.ComboBox
$AdapterList.text                = "Adapters"
$AdapterList.width               = 100
$AdapterList.height              = 20
$AdapterList.location            = New-Object System.Drawing.Point(149,62)
$AdapterList.Font                = 'Microsoft Sans Serif,10'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "1."
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(124,65)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "2."
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(124,103)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$PkgLine                         = New-Object system.Windows.Forms.ComboBox
$PkgLine.text                    = "Pkg Line"
$PkgLine.width                   = 100
$PkgLine.height                  = 20
$PkgLine.location                = New-Object System.Drawing.Point(148,98)
$PkgLine.Font                    = 'Microsoft Sans Serif,10'

$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.width              = 200
$ProgressBar1.height             = 21
$ProgressBar1.location           = New-Object System.Drawing.Point(98,351)

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Line IP Changer"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(149,18)
$Label3.Font                     = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($AdapterList,$Label1,$Label2,$PkgLineF,$ProgressBar1,$Label3))

$AdapterList.Add_DropDown({ Adapt })
$PkgLineF.Add_DropDown({ pkgline })


$adapts = @("Lenovo Dock", "Adapter 1")
$Pkg = @("Line 1", "Line 2", "Line 3", "Line 4","Line 5","Line 6", "Line 7", "Line 8", "Line 9", "Line 10","Line 11", "Line 12", "SFF")



#Write your logic code here

[void]$Form.ShowDialog()


function Adapt {
    
    Foreach($adapts1 in $adapts){
    
        $AdapterList.Items.Add($adapts1)
        }
    }
    
    function pkgline {
    
        Foreach($Pkgs in $Pkg){
    
            $PkgLineF.Items.Add($Pkgs)
            }
    
    }