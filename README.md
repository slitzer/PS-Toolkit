# PS-Toolkit

PowerShell-based multi-tool utility with a modern WPF UI (WinUtil-inspired).  
Run various audio, video, network, and system tasks via tabbed plugins.

## Features
- Audio to MP3 batch converter (FFmpeg-based, auto-downloads codec)
- Network diagnostics (ping, traceroute, speedtest)
- Extensible plugin system — drop new `.ps1` files in `Plugins/`
- Portable — runs from any folder, stores tools in local `Tools/`

## Requirements
- Windows 10 / 11
- PowerShell 5.1+ (default on Windows)
- .NET Framework / Windows Presentation Foundation (included in Windows)
- For speedtest: either Ookla Speedtest CLI (`speedtest`) or Python 3

## Installation
```powershell
# One-liner (replace YOURUSER with your GitHub username)
irm https://raw.githubusercontent.com/YOURUSER/PS-Toolkit/main/Install.ps1 | iex
```

Or clone manually:

```powershell
git clone https://github.com/YOURUSER/PS-Toolkit.git
cd PS-Toolkit
.\UI.ps1
```

## Usage
1. Run `UI.ps1` (or use the install script).
2. Tabs appear automatically from files in `Plugins/`.
3. Add your own plugins — each must return a `$tab` (`TabItem` object).

## Folder Structure
```text
PS-Toolkit/
├── Install.ps1          # GitHub one-liner launcher
├── UI.ps1               # Main WPF loader
├── Plugins/
│   ├── AudioToMP3.ps1
│   └── NetworkTest.ps1
└── Tools/               # Downloaded binaries (ffmpeg, etc.)
```

## Adding a Plugin
Create `Plugins/YourTool.ps1` and end with:

```powershell
$tab
```

It must return a `System.Windows.Controls.TabItem`.
