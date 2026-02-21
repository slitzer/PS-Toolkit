$tab = New-Object System.Windows.Controls.TabItem
$tab.Header = "Support Tool"

$gridXaml = @"
<Grid Margin='15' xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="5">
        <TextBox x:Name="txtTicket" Width="180" Height="35" Margin="5" Text="CW Ticket #" />
        <TextBox x:Name="txtComments" Width="400" Height="35" Margin="5" Text="Issue description" />
        <ComboBox x:Name="cmbRecipient" Width="250" Height="35" Margin="5">
            <ComboBoxItem Content="justin.cartwright@codeblue.co.nz" />
            <ComboBoxItem Content="james.doody@codeblue.co.nz" />
            <ComboBoxItem Content="cbsupport@wynnwilliams.co.nz" />
        </ComboBox>
    </StackPanel>

    <Button x:Name="btnRun" Grid.Row="1" Content="GENERATE & ZIP SUPPORT FILES" Width="350" Height="45" Margin="5" Background="#d35400" FontWeight="Bold" />

    <TextBox x:Name="txtLog" Grid.Row="2" Margin="5" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" IsReadOnly="True" Background="#1e1e1e" Foreground="#e0e0e0" FontFamily="Consolas" />

    <ProgressBar x:Name="prog" Grid.Row="3" Height="12" Margin="5" Visibility="Hidden"/>
</Grid>
"@

$grid = [Windows.Markup.XamlReader]::Parse($gridXaml)
$tab.Content = $grid

$txtTicket    = $grid.FindName("txtTicket")
$txtComments  = $grid.FindName("txtComments")
$cmbRecipient = $grid.FindName("cmbRecipient")
$btnRun       = $grid.FindName("btnRun")
$txtLog       = $grid.FindName("txtLog")
$prog         = $grid.FindName("prog")

$btnRun.Add_Click({
    if ($prog) { $prog.Visibility = "Visible" }
    $txtLog.Text = "Starting support collection...`n"

    $SupportPerson = $env:USERNAME
    $vComments     = $txtComments.Text.Trim()
    $vTicketNo     = $txtTicket.Text.Trim()
    $selectedRecipient = if ($cmbRecipient.SelectedItem) { $cmbRecipient.SelectedItem } else { $cmbRecipient.Items[0] }
    $emailper      = $selectedRecipient.Content

    $vUserName     = $env:USERNAME
    $vHostName     = $env:COMPUTERNAME
    $vTimestamp    = (Get-Date -Format "MM-dd-yyyy_HH_mm_ss")
    $basePath      = "C:\temps\CBSupportTool\$vUserName\$vHostName"
    $zipPath       = "C:\temps\CBSupportTool\$vUserName\CBSupport_$vTicketNo.zip"

    if (Test-Path "C:\temps\CBSupportTool\$vUserName") { Remove-Item "C:\temps\CBSupportTool\$vUserName" -Recurse -Force }
    New-Item -Path $basePath, "$basePath\Assets" -ItemType Directory -Force | Out-Null

    $txtLog.AppendText("Folders created.`n")

    # Uptime
    $uptimeSpan = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptime = "{0} Days, {1} Hours, {2} Minutes" -f $uptimeSpan.Days, $uptimeSpan.Hours, $uptimeSpan.Minutes
    $txtLog.AppendText("Uptime: $uptime`n")

    # Gather reports (non-interactive)
    netsh wlan show wlanreport | Out-Null
    Move-Item "C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html" "$basePath\Assets\wlan-report-latest.html" -Force -EA SilentlyContinue

    powercfg /batteryreport /output "$basePath\Assets\battery-report.html"
    powercfg -energy /output "$basePath\Assets\energy-report.html" -Duration 60

    # WMI collections → HTML fragments
    Get-CimInstance Win32_Processor          | Select Name, NumberOfCores, MaxClockSpeed | ConvertTo-Html -Fragment > "$basePath\Assets\CPU.html"
    Get-CimInstance Win32_PhysicalMemory     | Select Capacity, Speed, Manufacturer | ConvertTo-Html -Fragment > "$basePath\Assets\RAM.html"
    Get-CimInstance Win32_VideoController    | Select Name, AdapterRAM, DriverVersion | ConvertTo-Html -Fragment > "$basePath\Assets\GPU.html"
    Get-CimInstance Win32_BIOS               | Select Manufacturer, SMBIOSBIOSVersion, SerialNumber | ConvertTo-Html -Fragment > "$basePath\Assets\Bios.html"
    Get-CimInstance Win32_DiskDrive          | Select Model, SerialNumber, Size | ConvertTo-Html -Fragment > "$basePath\Assets\Disk.html"
    Get-CimInstance Win32_NetworkAdapter     | Select Name, MACAddress, Speed | ConvertTo-Html -Fragment > "$basePath\Assets\Network.html"
    Get-CimInstance Win32_OperatingSystem    | Select Caption, Version, InstallDate | ConvertTo-Html -Fragment > "$basePath\Assets\OS.html"
    Get-CimInstance Win32_LogicalDisk        | Select DeviceID, VolumeName, @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}} | ConvertTo-Html -Fragment > "$basePath\Assets\DiskDrives.html"

    $txtLog.AppendText("Reports generated.`n")

    # Zip
    Compress-Archive -Path "$basePath\*" -DestinationPath $zipPath -Force

    $txtLog.AppendText("Zip created: $zipPath`nReady to email to $emailper`n")
    if ($prog) { $prog.Visibility = "Hidden" }

    # Optional: open folder
    Invoke-Item "C:\temps\CBSupportTool\$vUserName"
})

$tab
