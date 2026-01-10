# Version Pattern Documentation

## Overview

VibeCodingYTPlayer follows a calendar-based versioning scheme that makes it easy to identify when a release was published.

## Version Format

**Pattern**: `YYYY.M.N`

Where:
- **YYYY** = Year (4 digits)
- **M** = Month (1-12, no leading zero)
- **N** = Release number for that month (starting from 1)

## Examples

| Version | Meaning |
|---------|---------|
| `2026.1.1` | First release in January 2026 |
| `2026.1.2` | Second release in January 2026 |
| `2026.2.1` | First release in February 2026 |
| `2026.12.3` | Third release in December 2026 |
| `2027.1.1` | First release in January 2027 |

## Current Version

**2026.1.1** - First release in January 2026

This is the initial public release of VibeCodingYTPlayer.

## Version History

### 2026.1.1 (January 10, 2026)
**Initial Release** 🎉

#### Features
- ✅ Audio-only playback from YouTube live streams and videos
- ✅ Menu bar integration (no Dock icon)
- ✅ Full playback controls (Play, Pause, Stop, Restart)
- ✅ Audio controls (Mute, Unmute, Toggle)
- ✅ Elapsed time tracking
- ✅ Keyboard shortcuts for all major actions
- ✅ URL persistence across app restarts
- ✅ Native macOS design with SwiftUI
- ✅ Comprehensive error handling
- ✅ Context menu with all controls
- ✅ Settings screen with URL validation
- ✅ "Open in Browser" functionality

#### Implementation Phases
- **Phase 1**: Project Setup & Architecture
- **Phase 2**: Core UI Structure
- **Phase 3**: Settings Screen Implementation
- **Phase 4**: User Defaults & URL Management
- **Phase 5**: Audio Playback Engine
- **Phase 6**: Main Screen Controls
- **Phase 7**: Live Stream Time Display
- **Phase 8**: Menu Bar Integration
- **Phase 9**: Polish & Testing
- **Phase 10**: Documentation & Release Prep

#### Technical Details
- Language: Swift 5
- Frameworks: SwiftUI, AVFoundation, AppKit, Combine
- External Dependencies: yt-dlp (command-line tool)
- Minimum macOS: 13.0 (Ventura)
- Build: Xcode 15+

#### Known Issues
- None reported

#### Credits
- Audio extraction powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp)

---

## Updating the Version

When creating a new release:

1. **Determine the version number**:
   - Same month as last release? → Increment N
   - New month? → Use M for new month, reset N to 1
   - New year? → Use new YYYY, M=1, N=1

2. **Update Info.plist**:
   ```xml
   <key>CFBundleShortVersionString</key>
   <string>YYYY.M.N</string>
   ```

3. **Update this document**:
   - Add new version to Version History
   - Update "Current Version" section
   - Document changes, features, and fixes

4. **Update README.md**:
   - Update version badge
   - Update "Current Version" in footer

5. **Create Git Tag**:
   ```bash
   git tag -a vYYYY.M.N -m "Release YYYY.M.N"
   git push origin vYYYY.M.N
   ```

6. **Create GitHub Release**:
   - Use the version as the release title
   - Include changelog from this document
   - Attach compiled .app binary

## Philosophy

This versioning scheme was chosen for several reasons:

1. **Clarity**: Immediately shows when a release was made
2. **Simplicity**: No semantic versioning confusion (major.minor.patch)
3. **Calendar-Based**: Natural progression with time
4. **User-Friendly**: Easy to understand for non-technical users
5. **Flexible**: Allows multiple releases per month if needed

## Comparison with SemVer

Traditional Semantic Versioning (SemVer) uses `MAJOR.MINOR.PATCH`:
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

Our calendar versioning is simpler and more transparent:
- Users don't need to understand what "breaking changes" mean
- Version numbers naturally increase with time
- Easy to identify how "recent" a release is

## Future Considerations

If the project grows significantly, we may:
- Add a build number for development builds
- Use alpha/beta suffixes for pre-releases (e.g., `2026.2.1-beta`)
- Add commit hash for nightly builds (e.g., `2026.2.1+a3f4b2c`)

For now, the simple `YYYY.M.N` pattern serves the project well.

---

**Last Updated**: January 10, 2026
**Current Version**: 2026.1.1
