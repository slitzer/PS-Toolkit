# Install.ps1 - updated for https://github.com/slitzer/PS-Toolkit.git

$AppName = "PSToolkit"
$PreferredPath = "C:\$AppName"
$FallbackPath = Join-Path $env:LOCALAPPDATA $AppName

try {
    New-Item "$PreferredPath\Plugins" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    $AppPath = $PreferredPath
}
catch {
    $AppPath = $FallbackPath
    New-Item "$AppPath\Plugins" -ItemType Directory -Force | Out-Null
}

irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/UI.ps1" -OutFile "$AppPath\UI.ps1"
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/AudioToMP3.ps1" -OutFile "$AppPath\Plugins/AudioToMP3.ps1"
$networkPluginPath = "$AppPath\Plugins/NetworkTest.ps1"
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/NetworkTest.ps1" -OutFile $networkPluginPath
irm "https://raw.githubusercontent.com/slitzer/PS-Toolkit/main/Plugins/SupportTool.ps1" -OutFile "$AppPath\Plugins/SupportTool.ps1"

# Safety migration for older NetworkTest content that used $host (read-only automatic variable collision)
$networkPluginContent = Get-Content -Path $networkPluginPath -Raw
if ($networkPluginContent -match '(?i)\$host\s*=') {
    $networkPluginContent = [regex]::Replace($networkPluginContent, '\$(?i:host)\b', '$targetHost')
    Set-Content -Path $networkPluginPath -Value $networkPluginContent -NoNewline
}

& "$AppPath\UI.ps1"
