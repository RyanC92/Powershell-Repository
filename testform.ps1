
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = 'Restore Sharepoint Files'
    $Form.Size = New-Object System.Drawing.Size(400,300)
    $Form.StartPosition = 'CenterScreen'
    $okb = New-Object System.Windows.Forms.Button
    $okb.Location = New-Object System.Drawing.Point(40,130)
    $okb.Size = New-Object System.Drawing.Size(75,25)
    $okb.Text = 'Submit'
    $okb.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $Form.AcceptButton = $okb
    $Form.Controls.Add($okb)
    $Form.CancelButton = $cb
    $Form.Controls.Add($cb)
    $CancelB = New-Object System.Windows.Forms.Button
    $CancelB.Location = New-Object System.Drawing.Point(200,130)
    $CancelB.Size = New-Object System.Drawing.Size(75,25)
    $CancelB.Text = 'close'
    $CancelB.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $Form.AcceptButton = $CancelB
    $Form.Controls.Add($CancelB)
    $lb = New-Object System.Windows.Forms.Label
    $lb.Location = New-Object System.Drawing.Point(40,40)
    $lb.Size = New-Object System.Drawing.Size(240,40)
    $lb.Text = "$($Question)"
    $Form.Controls.Add($lb)
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Location = New-Object System.Drawing.Point(40,80)
    $tb.Size = New-Object System.Drawing.Size(240,20)
    $Form.Controls.Add($tb)
    $Form.Topmost = $true
    $Form.Add_Shown({$tb.Select()})
    $rs = $Form.ShowDialog()

    if ($rs -eq [System.Windows.Forms.DialogResult]::OK){
        $y = $tb.Text
        Write-Host "Entered text is" -ForegroundColor Green
        $y
        }

