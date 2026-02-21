$AppPath=$PSScriptRoot;$PluginsPath="$AppPath\Plugins";$ToolsPath="$AppPath\Tools"
New-Item -Path $PluginsPath,$ToolsPath -ItemType Directory -Force|Out-Null
$global:ToolsPath=$ToolsPath;$global:FFmpegExe="$ToolsPath\ffmpeg\bin\ffmpeg.exe"
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Windows.Forms
$tabItems=@();Get-ChildItem "$PluginsPath\*.ps1" -EA SilentlyContinue|%{
  try{$tab=&$_.FullName;if($tab-is[System.Windows.Controls.TabItem]){$tabItems+=$tab}}catch{Write-Host "Plugin error $($_.Name): $($_.Exception.Message)" -F Red}}
$xaml=@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PSAudioTools" Height="650" Width="950" Background="#1e1e1e" Foreground="#ffffff" WindowStartupLocation="CenterScreen">
    <TabControl x:Name="MainTabs" Background="#252526" BorderBrush="#007acc"/>
</Window>
"@
$window=[Windows.Markup.XamlReader]::Parse($xaml);$tabControl=$window.FindName("MainTabs")
foreach($tab in $tabItems){if ($tab -and $tab -is [System.Windows.Controls.TabItem]) {$tabControl.Items.Add($tab)}}
if($tabControl.Items.Count -eq 0){
  $ph=New-Object System.Windows.Controls.TabItem;$ph.Header="Setup"
  $ph.Content=[Windows.Markup.XamlReader]::Parse('<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Text="No plugins found!&#10;Place *.ps1 files in Plugins folder&#10;Each must return $tab" FontSize="20" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#ff4444" TextAlignment="Center"/>')
  $tabControl.Items.Add($ph)
}
$window.ShowDialog()|Out-Null