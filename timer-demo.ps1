function Demo-Timer {
	
	Add-Type -AssemblyName System.Windows.Forms

	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object 'System.Windows.Forms.Form'
	$label000000 = New-Object 'System.Windows.Forms.Label'
	$timer1 = New-Object 'System.Windows.Forms.Timer'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'

	$form1_Load = {
		$script:countdown = [timespan]'00:00:30' # 10 minutes
		$label000000.Text = "$countdown"
		$timer1.Start()
	}
	
	$timer1_Tick = {
		$script:countdown -= [timespan]'00:00:01'
		$label000000.Text = "$countdown"
	}
	
	$Form_StateCorrection_Load =
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}
	
	$form1.SuspendLayout()
	$form1.Controls.Add($label000000)
	$form1.AutoScaleDimensions = '8, 17'
	$form1.AutoScaleMode = 'Font'
	$form1.BackColor = 'ActiveCaption'
	$form1.ClientSize = '265, 96'
	$form1.FormBorderStyle = 'FixedToolWindow'
	$form1.Name = 'form1'
	$form1.StartPosition = 'CenterScreen'
	$form1.Text = 'Shutdown Andrew!'
	$form1.add_Load($form1_Load)

	$label000000.AutoSize = $True
	$label000000.Font = 'Lucida Fax, 24pt, style=Bold'
	$label000000.Location = '27, 25'
	$label000000.Margin = '4, 0, 4, 0'
	$label000000.Name = 'label000000'
	$label000000.Size = '208, 46'
	$label000000.TabIndex = 0
	$label000000.Text = '00:00:00'

	$timer1.Interval = 1000
	$timer1.add_Tick($timer1_Tick)
	$form1.ResumeLayout()

	$InitialFormWindowState = $form1.WindowState
	$form1.add_Load($Form_StateCorrection_Load)
	return $form1.ShowDialog()
}
Demo-Timer