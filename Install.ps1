$AppName="PSAudioTools";$AppPath="C:\$AppName"
New-Item "$AppPath\Plugins" -ItemType Directory -Force|Out-Null
irm "https://raw.githubusercontent.com/YOURUSER/PSAudioTools/main/UI.ps1" -OutFile "$AppPath\UI.ps1"
irm "https://raw.githubusercontent.com/YOURUSER/PSAudioTools/main/Plugins/AudioToMP3.ps1" -OutFile "$AppPath\Plugins/AudioToMP3.ps1"
& "$AppPath\UI.ps1"