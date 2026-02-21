function Test-FFmpeg {return Test-Path $global:FFmpegExe}
function Install-FFmpeg {
    $zipPath="$global:ToolsPath\ffmpeg.zip";$extractPath="$global:ToolsPath\ffmpeg-temp"
    New-Item $extractPath -ItemType Directory -Force|Out-Null
    iwr "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl.zip" -OutFile $zipPath
    Expand-Archive $zipPath $extractPath -Force;Remove-Item $zipPath -Force
    $source=Get-ChildItem "$extractPath\ffmpeg-*-win64-gpl" -Directory|Select -First 1
    Rename-Item $source.FullName "$global:ToolsPath\ffmpeg";Remove-Item $extractPath -Recurse -Force
    return Test-FFmpeg
}
$tab=New-Object System.Windows.Controls.TabItem;$tab.Header="Audio → MP3"
$gridXaml=@"
<Grid Margin='15' xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Grid.RowDefinitions><RowDefinition Height='Auto'/><RowDefinition Height='Auto'/><RowDefinition Height='*'/><RowDefinition Height='Auto'/><RowDefinition Height='Auto'/></Grid.RowDefinitions>
    <StackPanel Orientation='Horizontal' Grid.Row='0'>
        <Button x:Name='btnFiles' Content='Select Files' Width='130' Height='35' Margin='5'/>
        <Button x:Name='btnFolder' Content='Select Folder' Width='130' Height='35' Margin='5'/>
    </StackPanel>
    <StackPanel Orientation='Horizontal' Grid.Row='1'>
        <TextBox x:Name='txtOut' Text='C:\MP3Converted' Width='420' Height='35' Margin='5'/>
        <Button x:Name='btnOut' Content='Browse' Width='90' Height='35' Margin='5'/>
    </StackPanel>
    <ListBox x:Name='lstFiles' Grid.Row='2' Margin='5' Background='#2d2d2d' Foreground='White'/>
    <StackPanel Orientation='Horizontal' Grid.Row='3'>
        <Button x:Name='btnDownload' Content='Download FFmpeg' Width='180' Height='38' Margin='5' Background='#d35400'/>
        <Button x:Name='btnConvert' Content='CONVERT TO MP3' Width='280' Height='38' Margin='5' Background='#007acc' FontSize='15' FontWeight='Bold'/>
    </StackPanel>
    <ProgressBar x:Name='prog' Grid.Row='4' Height='12' Margin='5' Visibility='Hidden'/>
</Grid>
"@
$grid=[Windows.Markup.XamlReader]::Parse($gridXaml)
$tab.Content=$grid
$btnFiles=$grid.FindName('btnFiles');$btnFolder=$grid.FindName('btnFolder');$txtOut=$grid.FindName('txtOut')
$btnOut=$grid.FindName('btnOut');$lst=$grid.FindName('lstFiles');$btnDownload=$grid.FindName('btnDownload')
$btnConvert=$grid.FindName('btnConvert');$prog=$grid.FindName('prog')
$btnDownload.IsEnabled=-not(Test-FFmpeg);$btnConvert.IsEnabled=Test-FFmpeg
$btnDownload.Add_Click({$btnDownload.Content='Downloading...';$btnDownload.IsEnabled=$false;if(Install-FFmpeg){$btnDownload.Content='✓ Ready';$btnConvert.IsEnabled=$true}else{$btnDownload.Content='Failed';$btnDownload.IsEnabled=$true}})
$btnFiles.Add_Click({$d=New-Object System.Windows.Forms.OpenFileDialog;$d.Multiselect=$true;$d.Filter='Audio|*.wav;*.mp3;*.ogg;*.flac;*.m4a;*.aac;*.opus;*.wma';if($d.ShowDialog() -eq 'OK'){$lst.Items.Clear();$d.FileNames|%{$lst.Items.Add($_)}}})
$btnFolder.Add_Click({$d=New-Object System.Windows.Forms.FolderBrowserDialog;if($d.ShowDialog() -eq 'OK'){$lst.Items.Clear();Get-ChildItem $d.SelectedPath -Recurse -File|?{$_.Extension -match '\.(wav|mp3|ogg|flac|m4a|aac|opus|wma)$'}|%{$lst.Items.Add($_.FullName)}}})
$btnOut.Add_Click({$d=New-Object System.Windows.Forms.FolderBrowserDialog;if($d.ShowDialog() -eq 'OK'){$txtOut.Text=$d.SelectedPath}})
$btnConvert.Add_Click({if($lst.Items.Count -eq 0){return};if ($prog) {$prog.Visibility='Visible'};$prog.Value=0;$c=$lst.Items.Count;$i=0;New-Item $txtOut.Text -ItemType Directory -Force|Out-Null;foreach($f in $lst.Items){$o=Join-Path $txtOut.Text ((Get-Item $f).BaseName+'.mp3');& $global:FFmpegExe -i `"$f`" -c:a libmp3lame -q:a 2 `"$o`" -y -loglevel quiet;$i++;$prog.Value=$i/$c*100};if ($prog) {$prog.Visibility='Hidden'}})
$tab