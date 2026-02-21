# Install.ps1 - updated for https://github.com/slitzer/PS-Toolkit.git

$AppName = "PSToolkit"
$AppPath = "C:\$AppName"
New-Item "$AppPath\Plugins" -ItemType Directory -Force | Out-Null

# Cache-bust raw GitHub fetches to avoid stale script content
$cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/UI.ps1?ts=$cacheBust" -OutFile "$AppPath\UI.ps1"
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/AudioToMP3.ps1?ts=$cacheBust" -OutFile "$AppPath\Plugins/AudioToMP3.ps1"
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/NetworkTest.ps1?ts=$cacheBust" -OutFile "$AppPath\Plugins/NetworkTest.ps1"

& "$AppPath\UI.ps1"
