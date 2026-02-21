# Install.ps1 - updated for https://github.com/slitzer/PS-Toolkit.git

$AppName = "PSToolkit"
$AppPath = "C:\$AppName"
New-Item "$AppPath\Plugins" -ItemType Directory -Force | Out-Null

irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/UI.ps1" -OutFile "$AppPath\UI.ps1"
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/AudioToMP3.ps1" -OutFile "$AppPath\Plugins/AudioToMP3.ps1"
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/NetworkTest.ps1" -OutFile "$AppPath\Plugins/NetworkTest.ps1"

& "$AppPath\UI.ps1"
