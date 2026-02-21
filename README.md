# PS-Toolkit


PowerShell-based multi-tool utility with a modern WPF UI (WinUtil-inspired).  
Run various audio, video, network, and system tasks via tabbed plugins.

## Features
- Audio to MP3 batch converter (FFmpeg-based, auto-downloads codec)
- Network diagnostics (ping, traceroute, speedtest)
- Extensible plugin system — drop new .ps1 files in `Plugins/`
- Portable — runs from any folder, stores tools in local `Tools/`

## Requirements
- Windows 10 / 11
- PowerShell 5.1+ (default on Windows)
- .NET Framework / Windows Presentation Foundation (included in Windows)
- For speedtest: Python 3 (optional, only if using NetworkTest speedtest button)

## Installation
```powershell
# One-liner (replace YOURUSER with your GitHub username)
irm https://raw.githubusercontent.com/YOURUSER/PSAudioTools/main/Install.ps1 | iex

Or clone manually:

git clone https://github.com/YOURUSER/PSAudioTools.git
cd PSAudioTools
.\UI.ps1

Usage

    Run UI.ps1 (or use the install script)
    Tabs appear automatically from files in Plugins/
    Add your own plugins — each must return a $tab (TabItem object)

Folder Structure

PSAudioTools/
├── Install.ps1          # GitHub one-liner launcher
├── UI.ps1               # Main WPF loader
├── Plugins/
│   ├── AudioToMP3.ps1
│   └── NetworkTest.ps1
└── Tools/               # Downloaded binaries (ffmpeg, etc.)

Adding a Plugin

Create Plugins/YourTool.ps1 and end with:

$tab

It must return a System.Windows.Controls.TabItem.
