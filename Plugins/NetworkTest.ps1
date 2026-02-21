$tab = New-Object System.Windows.Controls.TabItem
$tab.Header = "Network Test"

$gridXaml = @"
<Grid Margin='15' xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="5">
        <TextBox x:Name="txtHost" Text="8.8.8.8" Width="200" Height="35" Margin="5"/>
        <Button x:Name="btnPing" Content="Ping" Width="100" Height="35" Margin="5" Background="#007acc"/>
        <Button x:Name="btnTrace" Content="Traceroute" Width="120" Height="35" Margin="5" Background="#d35400"/>
        <Button x:Name="btnSpeed" Content="Speedtest" Width="120" Height="35" Margin="5" Background="#27ae60"/>
    </StackPanel>

    <TextBox x:Name="txtOutput" Grid.Row="1" Margin="5" Height="120" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" IsReadOnly="True" Background="#2d2d2d" Foreground="White" FontFamily="Consolas"/>

    <TextBox x:Name="txtResult" Grid.Row="2" Margin="5" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" IsReadOnly="True" Background="#1e1e1e" Foreground="#e0e0e0" FontFamily="Consolas" FontSize="13"/>

    <ProgressBar x:Name="prog" Grid.Row="3" Height="12" Margin="5" Visibility="Hidden"/>
</Grid>
"@

$grid = [Windows.Markup.XamlReader]::Parse($gridXaml)
$tab.Content = $grid

$txtHost   = $grid.FindName("txtHost")
$txtOutput = $grid.FindName("txtOutput")
$txtResult = $grid.FindName("txtResult")
$btnPing   = $grid.FindName("btnPing")
$btnTrace  = $grid.FindName("btnTrace")
$btnSpeed  = $grid.FindName("btnSpeed")
$prog      = $grid.FindName("prog")

$btnPing.Add_Click({
    if ($prog) { $prog.Visibility = "Visible" }
    if ($txtResult) { $txtResult.Text = "" }
    $targetHost = if ($txtHost) { $txtHost.Text.Trim() } else { "" }
    if (-not $targetHost) { if ($txtResult) { $txtResult.Text = "Enter host" }; if ($prog) { $prog.Visibility = "Hidden" }; return }

    if ($txtOutput) { $txtOutput.Text = "Pinging $targetHost ...`n`n" }
    $result = & ping -n 10 $targetHost | Out-String
    if ($txtResult) { $txtResult.Text = $result }
    if ($prog) { $prog.Visibility = "Hidden" }
})

$btnTrace.Add_Click({
    if ($prog) { $prog.Visibility = "Visible" }
    if ($txtResult) { $txtResult.Text = "" }
    $targetHost = if ($txtHost) { $txtHost.Text.Trim() } else { "" }
    if (-not $targetHost) { if ($txtResult) { $txtResult.Text = "Enter host" }; if ($prog) { $prog.Visibility = "Hidden" }; return }

    if ($txtOutput) { $txtOutput.Text = "Tracing route to $targetHost ...`n`n" }
    $result = & tracert -d -h 30 $targetHost | Out-String
    if ($txtResult) { $txtResult.Text = $result }
    if ($prog) { $prog.Visibility = "Hidden" }
})

$btnSpeed.Add_Click({
    if ($prog) { $prog.Visibility = "Visible" }
    if ($txtResult) { $txtResult.Text = "" }
    if ($txtOutput) { $txtOutput.Text = "Running speed test... (may take 20-60s)`n`n" }

    try {
        if (Get-Command speedtest -ErrorAction SilentlyContinue) {
            $result = & speedtest --accept-license --accept-gdpr --format=human-readable 2>&1 | Out-String
            if ($LASTEXITCODE -ne 0) { throw "Ookla Speedtest CLI failed" }
            if ($txtResult) { $txtResult.Text = $result -replace "`r", "" }
            return
        }

        if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
            throw "Python is not installed. Install Python 3 or Ookla Speedtest CLI."
        }

        $speedtestScript = irm "https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py" -UseBasicParsing
        $result = $speedtestScript | python - -q --simple 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0) { throw "Python speedtest-cli failed" }
        if ($txtResult) { $txtResult.Text = $result -replace "`r", "" }
    }
    catch {
        if ($txtResult) {
            $txtResult.Text = "Speedtest failed.`nInstall Ookla CLI: winget install Ookla.Speedtest.CLI`nOr install Python 3 and retry.`n`nError: $($_.Exception.Message)"
        }
    }
    finally { if ($prog) { $prog.Visibility = "Hidden" } }
})

$tab
