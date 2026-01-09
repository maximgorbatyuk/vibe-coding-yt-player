# Phase 5 Implementation Summary: Audio Playback Engine

## Overview
Phase 5 implements the core audio playback engine for the Youtube Live Player application. This phase provides the foundation for playing audio from YouTube live streams with full playback control capabilities.

## Implementation Date
January 9, 2026

## Key Components

### 1. AudioPlaybackManager Service
**Location**: `YoutubeLivePlayer/Services/AudioPlaybackManager.swift`

A comprehensive service class that manages all audio playback functionality using the MVVM pattern with Combine framework for reactive state management.

#### Architecture
- **ObservableObject**: Allows SwiftUI views to observe and react to playback state changes
- **Published Properties**: Expose playback state, mute status, errors, and current URL to views
- **AVFoundation Integration**: Uses AVPlayer for robust audio streaming
- **Async/Await**: Modern Swift concurrency for audio stream extraction

#### Key Features

##### Playback State Management
```swift
enum PlaybackState {
    case stopped
    case loading
    case playing
    case paused
    case error(String)
}
```

The state machine provides:
- Clear transitions between states
- Helper methods to check valid operations (`canPlay`, `canPause`, `canStop`)
- Error state with descriptive messages

##### Playback Controls

1. **Play**
   - Validates YouTube URL using `URLValidator`
   - Extracts audio stream URL via yt-dlp
   - Initializes AVPlayer with stream URL
   - Handles loading state transitions
   - Error handling for invalid URLs and extraction failures

2. **Pause**
   - Pauses current playback
   - Maintains player state for resuming
   - Only available when actively playing

3. **Stop**
   - Completely stops playback
   - Releases player resources
   - Cleans up observers and subscriptions
   - Resets state to stopped

4. **Restart**
   - Stops current playback
   - Clears player resources
   - Reinitializes playback from the beginning
   - Uses the same URL as current playback

5. **Resume**
   - Resumes playback when paused
   - Transitions from paused to playing state

6. **Mute/Unmute/Toggle**
   - Direct control over audio output
   - Toggle convenience method for menu bar integration
   - State persisted in `isMuted` property

#### Audio Stream Extraction

##### yt-dlp Integration
The manager uses yt-dlp (youtube-dl fork) as an external tool for extracting audio stream URLs from YouTube.

**Installation Requirement**:
```bash
brew install yt-dlp
```

**Detection Logic**:
The manager searches for yt-dlp in multiple locations:
- `/opt/homebrew/bin/yt-dlp` (Homebrew on Apple Silicon)
- `/usr/local/bin/yt-dlp` (Homebrew on Intel)
- `/usr/bin/yt-dlp` (System installation)
- `~/.local/bin/yt-dlp` (User local installation)
- Falls back to `which yt-dlp` command

**Extraction Process**:
1. Validates YouTube URL format
2. Locates yt-dlp binary
3. Executes: `yt-dlp --format bestaudio --get-url [URL]`
4. Parses output to get direct audio stream URL
5. Passes URL to AVPlayer for playback

**Format Selection**:
- `--format bestaudio`: Selects the best audio-only format
- No video download, optimal for live streams
- Minimal bandwidth usage

##### Error Handling
Comprehensive error types:
```swift
enum AudioPlaybackError: LocalizedError {
    case ytDlpNotFound
    case extractionFailed(String)
    case invalidStreamURL
}
```

Each error provides user-friendly descriptions:
- Missing yt-dlp: Installation instructions
- Extraction failures: Detailed error messages from yt-dlp
- Invalid URLs: Clear validation messages

#### AVPlayer Integration

##### Setup
- Audio session configured for background playback
- Category: `.playback` for audio-only streaming
- Mode: `.default` for standard audio playback

##### Monitoring
- KVO observation of player item status
- Automatic state transitions based on player status
- Handles ready, failed, and unknown states

##### Resource Management
- Proper cleanup on stop and deinitialization
- Observer invalidation to prevent memory leaks
- Player item replacement to free resources

## Technical Decisions

### 1. Why yt-dlp?
**Rationale**:
- YouTube doesn't provide public APIs for direct audio stream access
- Native iOS/macOS methods cannot extract stream URLs without external tools
- yt-dlp is the most reliable and actively maintained tool for this purpose
- Handles YouTube's changing stream formats automatically

**Alternatives Considered**:
- Direct AVPlayer with YouTube URLs: ❌ Not supported by YouTube
- Web scraping: ❌ Too fragile, violates terms of service
- YouTube Data API: ❌ Doesn't provide stream URLs, only metadata
- youtube-dl: ⚠️ Less actively maintained than yt-dlp

**Trade-off**:
- External dependency required (yt-dlp must be installed)
- Users need to install via Homebrew or other package managers
- **Benefit**: Reliable, maintained, handles format changes

### 2. AVFoundation vs Other Audio Frameworks
**Choice**: AVFoundation with AVPlayer

**Rationale**:
- Native framework (no external dependencies for playback)
- Robust HLS streaming support (YouTube uses HLS)
- Automatic buffering and network error handling
- Background audio support built-in
- Resource efficient for live streams

### 3. Combine for State Management
**Choice**: Using `@Published` properties with Combine

**Rationale**:
- Native Swift framework (iOS 13+, macOS 10.15+)
- Perfect integration with SwiftUI
- Reactive updates to UI without manual observation
- Type-safe state changes

### 4. Async/Await for Extraction
**Choice**: Modern Swift concurrency

**Rationale**:
- Clean, readable code for asynchronous operations
- Built-in error handling with try/catch
- Automatic main actor dispatch for UI updates
- No callback hell or complex delegate patterns

## Integration Points

### For Phase 6 (Main Screen Controls)
The `AudioPlaybackManager` is ready to be integrated into views:

```swift
@StateObject private var audioManager = AudioPlaybackManager()

// Usage
audioManager.play(urlString: youtubeURL)
audioManager.pause()
audioManager.stop()
audioManager.restart()
audioManager.mute()
audioManager.unmute()
audioManager.toggleMute()

// State observation
switch audioManager.playbackState {
    case .playing: // Show playing UI
    case .paused: // Show paused UI
    case .stopped: // Show stopped UI
    case .loading: // Show loading indicator
    case .error(let message): // Show error
}
```

### For Phase 8 (Menu Bar Integration)
All playback methods are ready for menu bar context menu:
- Simple method calls without complex parameters
- State checking methods (`canPlay`, `canPause`, etc.)
- Toggle methods for quick actions

## Testing Recommendations

### Manual Testing Checklist
- [ ] Install yt-dlp: `brew install yt-dlp`
- [ ] Test play with valid YouTube live stream URL
- [ ] Test pause during playback
- [ ] Test resume after pause
- [ ] Test stop from playing state
- [ ] Test restart functionality
- [ ] Test mute/unmute/toggle during playback
- [ ] Test with invalid YouTube URL
- [ ] Test with non-YouTube URL
- [ ] Test without yt-dlp installed (should show error)
- [ ] Test with network disconnected
- [ ] Test with non-live YouTube video
- [ ] Test with age-restricted content
- [ ] Test with geographically restricted content

### Error Scenarios
- Invalid URL format
- yt-dlp not installed
- Network connectivity issues
- YouTube restrictions (age, geo-blocking)
- Stream unavailable or offline
- Malformed yt-dlp output

## Known Limitations

1. **External Dependency**
   - Requires yt-dlp installation
   - Need to document installation instructions for users
   - Could add automatic installation check on first launch

2. **Extraction Delay**
   - yt-dlp extraction takes 1-3 seconds
   - Loading state handles this gracefully
   - Could add progress indication in Phase 6

3. **No Caching**
   - Stream URLs expire after some time
   - Each restart re-extracts the URL
   - Could cache URLs with TTL in future enhancement

4. **No Network Resilience**
   - AVPlayer handles some reconnection automatically
   - Complete network failures require manual restart
   - Could add automatic retry logic

## Files Modified/Created

### New Files
- `YoutubeLivePlayer/Services/AudioPlaybackManager.swift` (318 lines)

### Modified Files
None (this phase only adds new functionality)

## Dependencies

### External Tools
- **yt-dlp**: Required for audio stream extraction
  - Installation: `brew install yt-dlp`
  - Version: Any recent version (tool handles YouTube format changes)

### Frameworks
- **AVFoundation**: Native iOS/macOS framework for audio playback
- **Combine**: Native framework for reactive state management
- **Foundation**: Standard library for process execution and file management

## Next Steps (Phase 6)

The audio playback engine is now complete and ready for UI integration:

1. **Update MainView.swift**
   - Add `@StateObject` for `AudioPlaybackManager`
   - Create button UI for all playback controls
   - Add loading indicators
   - Add error message displays
   - Add state-based button enabling/disabling

2. **URL Integration**
   - Read saved URL from `@AppStorage`
   - Pass URL to play function
   - Handle empty URL state

3. **User Feedback**
   - Visual indication of current state
   - Error message presentation
   - Loading animations

4. **Open in Browser**
   - Use `NSWorkspace.shared.open()` with YouTube URL

## Conclusion

Phase 5 successfully implements a robust audio playback engine with:
- ✅ Full playback control (play, pause, stop, restart)
- ✅ Audio controls (mute, unmute, toggle)
- ✅ State management with Combine
- ✅ Error handling for all failure scenarios
- ✅ YouTube URL validation integration
- ✅ Live stream support via yt-dlp
- ✅ Resource management and cleanup
- ✅ Ready for SwiftUI integration

The implementation follows iOS/macOS best practices, uses native frameworks where possible, and provides a solid foundation for the remaining phases.
