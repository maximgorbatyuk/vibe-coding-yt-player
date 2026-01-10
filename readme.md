# Youtube Live Player

A minimalist macOS menu bar application for playing audio from YouTube live streams and videos.

![Version](https://img.shields.io/badge/version-2026.1.1-blue)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5-orange)

## Overview

Youtube Live Player is a lightweight macOS menu bar app that allows you to listen to YouTube live streams and videos as audio-only, without keeping a browser tab open. The app runs entirely from the menu bar, keeping your desktop clean while you enjoy your favorite content.

### Key Features

- 🎵 **Audio-only playback** from YouTube live streams and videos
- 📍 **Menu bar integration** - no Dock icon, stays out of your way
- ⚡️ **Full playback controls** - Play, Pause, Stop, Restart
- 🔇 **Audio controls** - Mute, Unmute, Toggle
- ⏱️ **Elapsed time tracking** - See how long you've been listening
- ⌨️ **Keyboard shortcuts** - Control playback without touching the mouse
- 💾 **URL persistence** - Your last URL is saved and restored
- 🎨 **Native macOS design** - Follows Apple's Human Interface Guidelines
- 🔒 **Privacy-focused** - Minimal dependencies, no analytics

## Requirements

- macOS 13.0 (Ventura) or later
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed (see Installation)

## Installation

### 1. Install yt-dlp

Youtube Live Player requires `yt-dlp` to extract audio streams from YouTube. Install it using Homebrew:

```bash
brew install yt-dlp
```

Or download from the [official repository](https://github.com/yt-dlp/yt-dlp#installation).

### 2. Install Youtube Live Player

#### Option A: Build from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/YoutubeLivePlayer.git
   cd YoutubeLivePlayer
   ```

2. Open in Xcode:
   ```bash
   open YoutubeLivePlayer.xcodeproj
   ```

3. Build and run (⌘R) or create an archive for distribution

## Usage

### Getting Started

1. **Launch the app** - Look for the music note icon (🎵) in your menu bar
2. **Set your YouTube URL**:
   - Click the menu bar icon
   - Navigate to the Settings tab
   - Paste a YouTube URL (live stream or regular video)
3. **Start listening**:
   - Go back to the Main tab
   - Click the Play button
   - Enjoy audio-only playback!

### Main Screen Controls

The Main screen provides all your playback controls:

#### Playback Controls
- **Play** ▶️ - Start playing the audio (⌘P)
- **Pause** ⏸ - Pause playback
- **Stop** ⏹ - Stop playback and reset time (⌘S)
- **Restart** 🔄 - Restart from the beginning (⌘R)

#### Audio Controls
- **Mute** 🔇 - Mute the audio (⌘M)
- **Unmute** 🔊 - Unmute the audio
- **Toggle Audio** 🔀 - Switch between mute/unmute (⌘T)

#### Additional Actions
- **Open in Browser** 🌐 - Open the current URL in your default browser (⌘B)
- **Quit** ⏻ - Exit the application (⌘Q)

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Play | ⌘P |
| Stop | ⌘S |
| Restart | ⌘R |
| Mute | ⌘M |
| Toggle Audio | ⌘T |
| Open in Browser | ⌘B |
| Show Window | ⌘W |
| Quit | ⌘Q |

### Status Indicators

The Main screen shows your current playback state:

- **🟢 Playing** - Audio is currently playing
- **🟠 Paused** - Playback is paused
- **⚪️ Stopped** - No active playback
- **🔵 Loading...** - Extracting audio stream (with spinner)
- **🔴 Error** - An error occurred (with details)

When muted, a 🔇 indicator appears next to the playback state.

## Supported YouTube URL Formats

The app accepts these YouTube URL formats:

- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtube.com/watch?v=VIDEO_ID`
- `https://m.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/live/VIDEO_ID`

## Troubleshooting

### "yt-dlp is not installed" Error

**Solution**: Install yt-dlp using Homebrew:
```bash
brew install yt-dlp
```

If you've installed yt-dlp but still see the error, verify the installation:
```bash
which yt-dlp
```

### "Unable to load the audio stream" Error

**Possible causes and solutions**:

1. **Invalid URL**: Verify the YouTube URL is correct
2. **No internet connection**: Check your network connection
3. **Video unavailable**: The video may be private, deleted, or region-locked
4. **Live stream not started**: Wait until the stream begins
5. **yt-dlp needs update**: Update yt-dlp to the latest version:
   ```bash
   brew upgrade yt-dlp
   ```

## Technical Details

### Architecture

- **Language**: Swift 5
- **Frameworks**: SwiftUI, AVFoundation, AppKit, Combine
- **External Tools**: yt-dlp (for audio extraction)
- **Minimum macOS**: 13.0 (Ventura)

### Version Pattern

Version numbers follow the pattern: **YYYY.M.N**
- **YYYY**: Year (e.g., 2026)
- **M**: Month (1-12)
- **N**: Release number for that month

Example: `2026.1.1` = First release in January 2026

## FAQ

**Q: Does this download videos?**
A: No, it streams audio directly without downloading.

**Q: Can I play regular videos (not just live streams)?**
A: Yes! Despite the name, it works with any YouTube video or live stream.

**Q: Does it work with private/unlisted videos?**
A: Only if the URL is publicly accessible. Private and members-only videos won't work.

**Q: Is there a Windows/Linux version?**
A: Not currently. This is a macOS-specific application.

---

**Made with ❤️ for the macOS community**

Current Version: **2026.1.1** | Released: January 2026
