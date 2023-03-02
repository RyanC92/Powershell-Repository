# Load the required assemblies
Add-Type -AssemblyName System.Windows.Forms

# Create the form and its controls
$form = New-Object System.Windows.Forms.Form
$textBox = New-Object System.Windows.Forms.TextBox
$button1 = New-Object System.Windows.Forms.Button
$button2 = New-Object System.Windows.Forms.Button
$button3 = New-Object System.Windows.Forms.Button
$panel = New-Object System.Windows.Forms.Panel


# Configure the form
$form.Text = "Turner Fixes"
$form.Size = New-Object System.Drawing.Size(355, 150)
$form.StartPosition = "CenterScreen"
$form.AutoScale = $true

# Configure the buttons
$button1.Location = New-Object System.Drawing.Size(10, 10)
$button1.Size = New-Object System.Drawing.Size(100, 40)
$button1.Text = "Apply SAP Connection Fix"
$button2.Location = New-Object System.Drawing.Size(120, 10)
$button2.Size = New-Object System.Drawing.Size(100, 40)
$button2.Text = "Apply Office Macro Fix"
$button3.Location = New-Object System.Drawing.Size(230,10)
$button3.Size = New-Object System.Drawing.Size(100,40)
$button3.Text = "Apply All Fixes"
#$richtextBox.Location = New-Object System.Drawing.Point (10,75)
#$richtextBox.Size = New-Object System.Drawing.Size(900,250)
#$richtextBox.AutoSize = $True
$label = New-Object System.Windows.Forms.Label
$label.autosize = $false
$label.TextAlign = [System.Drawing.ContentAlignment]::BottomCenter
$label.Dock = [System.Windows.Forms.DockStyle]::Fill
#$label.Size = New-Object System.Drawing.Size(250,45)
#$label.Location = New-Object System.Drawing.Point(75,60)


# Add the controls to the form

$form.Controls.Add($button1)
$form.Controls.Add($button2)
$form.Controls.Add($button3)
$form.Controls.Add($label)

# Define the event handlers for the buttons
$button1_Click = {
    Write-Host "Apply SAP Fix"
    #Apply SAP Connection Fix
    xcopy "\\tcco.org\tccofile1\TSE_Downloads\SAP Connections Fix\SAP Connections Fix\SAPUILandscapes\*" C:\SAP /y
    $RegistryPath1  = 'HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment'
    $exists = Test-Path -Path $RegistryPath1
    if (!$exists) {$null = New-item -Path $RegistryPath1 -Force}

    #Write the registry values
    'Name, Value, Type
    PLMVIS_82_LIBPATH,"C:\\Program Files (x86)\\SAP\\FrontEnd\\SAPgui\\Program",REG_SZ
    SAPLOGON_INI_FILE,"C:\\SAP\\SAPLOGON.INI",REG_SZ
    SAPLOGON_LSXML_FILE,"C:\\SAP\\SAPUILANDSCAPE.XML", REG_SZ
    SNC_LIB,"C:\\SAP\\gsskrb5.dll",REG_SZ
    SNC_LIB_32,"C:\\SAP\\gsskrb5.dll",REG_SZ
    SNC_LIB_64,"C:\\SAP\\gx64krb5.dll",REG_SZ' |
    ConvertFrom-Csv |
    Set-ItemProperty -Path $RegistryPath1 -Name {$_.Name}

    $label.Text = "SAP Fix Applied, You may close the window."

}

$button2_Click = {
    # Apply Office Macro Fix
    Write-Host "Apply Office Macro Fix"
    $RegistryPath1 = 'REGISTRY::HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{5B076C03-2F26-11CF-9AE5-0800096E19F4}'
    $exists = Test-Path -Path $RegistryPath1
    if (!$exists) {$null = New-item -Path $RegistryPath1 -Force}
    'Name, Value, Type
    @,"SAP Remote Function Call", REG_SZ
    AppID, {5B076C03-2F26-11CF-9AE5-0800096E19F4}, REG_SZ' |
    ConvertFrom-Csv |
    Set-itemProperty -Path $RegistryPath1 -Name {$_.Name}

    $RegistryPath2 = 'REGISTRY::HKEY_CLASSES_ROOT\WOW6432Node\AppID\{5B076C03-2F26-11CF-9AE5-0800096E19F4}'
    $exists = Test-Path -Path $RegistryPath2
    if (!$exists) {$null = New-item -Path $RegistryPath2 -Force}
    'Name, Value, Type
    DllSurrogate,"",REG_SZ'|
    ConvertFrom-Csv |
    Set-itemProperty -Path $RegistryPath2 -Name {$_.Name}

    $RegistryPath3 = 'HKLM:\SOFTWARE\Classes\AppID\{5B076C03-2F26-11CF-9AE5-0800096E19F4}'
    $exists = Test-Path -Path $RegistryPath3
    if (!$exists) {$null = New-item -Path $RegistryPath3 -Force}
    'Name, Value, Type
    DllSurrogate,"",REG_SZ'|
    ConvertFrom-Csv |
    Set-itemProperty -Path $RegistryPath3 -Name {$_.Name}

    $label.Text = "Office Macro Fix Applied, You may close the window."
}

$button3_Click = {
    # Apply all fixes
    #SAP Connection Fix
    xcopy "\\tcco.org\tccofile1\TSE_Downloads\SAP Connections Fix\SAP Connections Fix\SAPUILandscapes\*" C:\SAP /y
    $RegistryPath1  = 'HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment'
    $exists = Test-Path -Path $RegistryPath1
    if (!$exists) {$null = New-item -Path $RegistryPath1 -Force}

    #Write the registry values
    'Name, Value, Type
    PLMVIS_82_LIBPATH,"C:\\Program Files (x86)\\SAP\\FrontEnd\\SAPgui\\Program",REG_SZ
    SAPLOGON_INI_FILE,"C:\\SAP\\SAPLOGON.INI",REG_SZ
    SAPLOGON_LSXML_FILE,"C:\\SAP\\SAPUILANDSCAPE.XML", REG_SZ
    SNC_LIB,"C:\\SAP\\gsskrb5.dll",REG_SZ
    SNC_LIB_32,"C:\\SAP\\gsskrb5.dll",REG_SZ
    SNC_LIB_64,"C:\\SAP\\gx64krb5.dll",REG_SZ' |
    ConvertFrom-Csv |
    Set-ItemProperty -Path $RegistryPath1 -Name {$_.Name}

    # Office Macro Fix

    Write-Host "Apply Office Macro Fix"
    $RegistryPath2 = 'REGISTRY::HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{5B076C03-2F26-11CF-9AE5-0800096E19F4}'
    $exists = Test-Path -Path $RegistryPath2
    if (!$exists) {$null = New-item -Path $RegistryPath2 -Force}
    'Name, Value, Type
    @,"SAP Remote Function Call", REG_SZ
    AppID, {5B076C03-2F26-11CF-9AE5-0800096E19F4}, REG_SZ' |
    ConvertFrom-Csv |
    Set-itemProperty -Path $RegistryPath2 -Name {$_.Name}

    $RegistryPath3 = 'REGISTRY::HKEY_CLASSES_ROOT\WOW6432Node\AppID\{5B076C03-2F26-11CF-9AE5-0800096E19F4}'
    $exists = Test-Path -Path $RegistryPath3
    if (!$exists) {$null = New-item -Path $RegistryPath3 -Force}
    'Name, Value, Type
    DllSurrogate,"",REG_SZ'|
    ConvertFrom-Csv |
    Set-itemProperty -Path $RegistryPath3 -Name {$_.Name}

    $RegistryPath4 = 'HKLM:\SOFTWARE\Classes\AppID\{5B076C03-2F26-11CF-9AE5-0800096E19F4}'
    $exists = Test-Path -Path $RegistryPath4
    if (!$exists) {$null = New-item -Path $RegistryPath4 -Force}
    'Name, Value, Type
    DllSurrogate,"",REG_SZ'|
    ConvertFrom-Csv |
    Set-itemProperty -Path $RegistryPath4 -Name {$_.Name}

    $label.Text = "All Fixes have been Applied, You may close the window."

}

# Assign the event handlers to the buttons
$button1.Add_Click($button1_Click)
$button2.Add_Click($button2_Click)
$button3.Add_Click($button3_Click)

# Show the form
$form.ShowDialog()