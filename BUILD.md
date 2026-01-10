# Build & Release Process Documentation

## Overview

This document describes the build and release process for VibeCodingYTPlayer, a macOS menu bar application.

## Prerequisites

### Development Environment

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **Command Line Tools**: Installed via `xcode-select --install`
- **yt-dlp**: Installed for testing (`brew install yt-dlp`)

### Required Accounts (for distribution)

- **Apple Developer Account**: Required for code signing and notarization
- **GitHub Account**: For repository hosting and releases

## Development Build

### Quick Development Build

For local development and testing:

```bash
# Clone the repository
git clone https://github.com/yourusername/VibeCodingYTPlayer.git
cd VibeCodingYTPlayer

# Open in Xcode
open VibeCodingYTPlayer.xcodeproj

# Build and run (⌘R in Xcode)
# Or via command line:
xcodebuild -scheme VibeCodingYTPlayer -configuration Debug build
```

### Running from Xcode

1. Open `VibeCodingYTPlayer.xcodeproj` in Xcode
2. Select the "VibeCodingYTPlayer" scheme
3. Press ⌘R (or Product → Run)
4. The app will appear in the menu bar
5. Use breakpoints and debugging as needed

### Build Configurations

- **Debug**: For development with debug symbols and optimizations disabled
- **Release**: For distribution with optimizations enabled

## Release Build

### Step 1: Prepare for Release

#### 1.1 Update Version Number

Edit `VibeCodingYTPlayer/Info.plist`:

```xml
<key>CFBundleShortVersionString</key>
<string>YYYY.M.N</string>
<key>CFBundleVersion</key>
<string>1</string>
```

Follow the version pattern documented in `VERSION.md`.

#### 1.2 Update Documentation

- [ ] Update `VERSION.md` with new version and changelog
- [ ] Update `README.md` version badge and footer
- [ ] Review and update `IMPLEMENTATION_PLAN.md` if needed

#### 1.3 Run Tests

```bash
# Build for release configuration
xcodebuild -scheme VibeCodingYTPlayer -configuration Release clean build

# Verify no errors
echo $?  # Should output 0
```

#### 1.4 Code Review

- Review all recent changes
- Check for debug print statements
- Verify error messages are user-friendly
- Ensure all features work as expected

### Step 2: Create Archive

#### 2.1 Archive via Xcode

1. Open `VibeCodingYTPlayer.xcodeproj` in Xcode
2. Select "Any Mac" as the destination
3. Product → Archive
4. Wait for the archive to complete
5. The Organizer window will open automatically

#### 2.2 Archive via Command Line

```bash
xcodebuild archive \
    -scheme VibeCodingYTPlayer \
    -configuration Release \
    -archivePath "./build/VibeCodingYTPlayer.xcarchive"
```

### Step 3: Export for Distribution

#### 3.1 Export Options

Choose one based on your distribution method:

**Option A: Developer ID Application (Recommended)**
- For distribution outside the Mac App Store
- Requires Apple Developer account
- Can be distributed via download

**Option B: Mac App Store**
- For distribution through Mac App Store
- Requires App Store Connect account
- Subject to App Review

**Option C: Development (Testing Only)**
- For testing on registered devices
- Not for public distribution

#### 3.2 Export via Xcode

1. In Organizer, select your archive
2. Click "Distribute App"
3. Choose "Developer ID" or "Mac App Store"
4. Follow the export wizard
5. Choose a save location
6. Xcode will create a `.app` bundle

#### 3.3 Export via Command Line

Create `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

Then export:

```bash
xcodebuild -exportArchive \
    -archivePath "./build/VibeCodingYTPlayer.xcarchive" \
    -exportPath "./build/export" \
    -exportOptionsPlist "./ExportOptions.plist"
```

### Step 4: Code Signing & Notarization

#### 4.1 Verify Code Signature

```bash
codesign --verify --deep --strict --verbose=2 "./build/export/VibeCodingYTPlayer.app"
```

Expected output:
```
./build/export/VibeCodingYTPlayer.app: valid on disk
./build/export/VibeCodingYTPlayer.app: satisfies its Designated Requirement
```

#### 4.2 Notarize the Application

Notarization is required for Gatekeeper to allow first-run without warnings.

```bash
# Create a ZIP for notarization
cd ./build/export
zip -r "VibeCodingYTPlayer.zip" "VibeCodingYTPlayer.app"

# Submit for notarization
xcrun notarytool submit VibeCodingYTPlayer.zip \
    --apple-id "your@email.com" \
    --password "app-specific-password" \
    --team-id "YOUR_TEAM_ID" \
    --wait

# Staple the notarization ticket
xcrun stapler staple "VibeCodingYTPlayer.app"
```

#### 4.3 Verify Notarization

```bash
spctl -a -t exec -vv "VibeCodingYTPlayer.app"
```

Expected output:
```
VibeCodingYTPlayer.app: accepted
source=Notarized Developer ID
```

### Step 5: Create Distribution Package

#### 5.1 Create DMG (Recommended)

```bash
# Create a DMG for distribution
hdiutil create -volname "VibeCodingYTPlayer" \
    -srcfolder "VibeCodingYTPlayer.app" \
    -ov -format UDZO \
    "VibeCodingYTPlayer-YYYY.M.N.dmg"
```

#### 5.2 Or Create ZIP

```bash
# Create a ZIP for distribution
zip -r "VibeCodingYTPlayer-YYYY.M.N.zip" "VibeCodingYTPlayer.app"
```

### Step 6: Test the Build

#### 6.1 Fresh Install Test

1. Quit the app if running
2. Delete any existing installation
3. Clear saved preferences:
   ```bash
   defaults delete mgorbatyuk.dev.VibeCodingYTPlayer
   ```
4. Install from the distribution package
5. Test all features:
   - [ ] App appears in menu bar
   - [ ] Settings URL input works
   - [ ] Playback controls work
   - [ ] Audio controls work
   - [ ] Menu bar context menu works
   - [ ] Keyboard shortcuts work
   - [ ] "Open in Browser" works
   - [ ] Quit works from all locations

#### 6.2 Gatekeeper Test

Test that macOS Gatekeeper allows the app:

```bash
xattr -d com.apple.quarantine "VibeCodingYTPlayer.app"
open "VibeCodingYTPlayer.app"
```

### Step 7: Create Git Tag

```bash
# Commit all changes
git add .
git commit -m "Release YYYY.M.N"

# Create annotated tag
git tag -a vYYYY.M.N -m "Release YYYY.M.N

Changes in this release:
- Feature 1
- Feature 2
- Bug fix 1
"

# Push commits and tags
git push origin main
git push origin vYYYY.M.N
```

### Step 8: Create GitHub Release

#### 8.1 Via GitHub Web Interface

1. Go to your repository on GitHub
2. Click "Releases" → "Draft a new release"
3. Choose the tag `vYYYY.M.N`
4. Release title: "VibeCodingYTPlayer YYYY.M.N"
5. Description: Copy changelog from `VERSION.md`
6. Upload the DMG or ZIP file
7. Click "Publish release"

#### 8.2 Via GitHub CLI

```bash
# Install gh if not already installed
brew install gh

# Create release
gh release create vYYYY.M.N \
    "VibeCodingYTPlayer-YYYY.M.N.dmg" \
    --title "VibeCodingYTPlayer YYYY.M.N" \
    --notes-file RELEASE_NOTES.md
```

### Step 9: Post-Release

#### 9.1 Update Documentation

- [ ] Verify README.md is up to date
- [ ] Update VERSION.md with release date
- [ ] Create `PHASE_N_SUMMARY.md` if applicable

#### 9.2 Announcements (Optional)

- Tweet about the release
- Post on relevant forums/communities
- Update any landing pages

#### 9.3 Monitor for Issues

- Watch GitHub issues for bug reports
- Monitor user feedback
- Prepare hotfix process if needed

## Continuous Integration (Future)

### GitHub Actions Workflow (Planned)

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild -scheme VibeCodingYTPlayer -configuration Release build
      - name: Archive
        run: xcodebuild archive -scheme VibeCodingYTPlayer -archivePath ./build/VibeCodingYTPlayer.xcarchive
      - name: Export
        run: xcodebuild -exportArchive -archivePath ./build/VibeCodingYTPlayer.xcarchive -exportPath ./build/export
      - name: Create DMG
        run: hdiutil create -volname "VibeCodingYTPlayer" -srcfolder ./build/export -ov -format UDZO VibeCodingYTPlayer.dmg
      - name: Upload Release Asset
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ./VibeCodingYTPlayer.dmg
          asset_name: VibeCodingYTPlayer-${{ github.ref_name }}.dmg
          asset_content_type: application/octet-stream
```

## Hotfix Process

If a critical bug is found after release:

1. Create a hotfix branch from the release tag:
   ```bash
   git checkout -b hotfix/YYYY.M.N+1 vYYYY.M.N
   ```

2. Fix the issue
3. Increment the release number (N)
4. Follow the release process above
5. Merge hotfix back to main:
   ```bash
   git checkout main
   git merge hotfix/YYYY.M.N+1
   git branch -d hotfix/YYYY.M.N+1
   ```

## Build Troubleshooting

### Common Issues

#### Code Signing Failed
**Solution**: Verify your Apple Developer certificates are installed:
```bash
security find-identity -v -p codesigning
```

#### Archive Failed
**Solution**: Clean build folder and try again:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean -scheme VibeCodingYTPlayer
```

#### Notarization Failed
**Solution**: Check notarization log:
```bash
xcrun notarytool log <submission-id> --apple-id "your@email.com" --password "app-specific-password"
```

#### App Doesn't Run on Other Macs
**Solution**: Ensure code signing and notarization were successful. Check quarantine attribute:
```bash
xattr -l "VibeCodingYTPlayer.app"
```

## File Structure

```
VibeCodingYTPlayer/
├── VibeCodingYTPlayer.xcodeproj    # Xcode project
├── VibeCodingYTPlayer/              # Source code
│   ├── VibeCodingYTPlayerApp.swift # App entry point
│   ├── Views/                      # SwiftUI views
│   ├── Services/                   # Business logic
│   ├── Models/                     # Data models
│   └── Info.plist                  # App configuration
├── build/                          # Build output (gitignored)
│   ├── VibeCodingYTPlayer.xcarchive # Archive
│   └── export/                     # Exported app
├── README.md                       # User documentation
├── BUILD.md                        # This file
├── VERSION.md                      # Version history
└── IMPLEMENTATION_PLAN.md          # Development plan
```

## Environment Variables

For automated builds, you may want to set:

```bash
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
```

## Security Considerations

### Code Signing Certificate

- Keep your Developer ID certificate secure
- Use Xcode to manage certificates
- Don't commit certificates to Git
- Rotate certificates before expiration

### App-Specific Password

- Create an app-specific password for notarization
- Store it in Keychain, not in scripts
- Don't commit passwords to Git

### Entitlements

Current entitlements (none required for this app):
- App Sandbox: No (required for menu bar functionality)
- Hardened Runtime: Yes (required for notarization)
- Network: Allowed (for audio streaming)

## Performance Optimization

### Build Time Optimization

- Use `xcodebuild -jobs` to parallelize builds
- Enable compiler optimization for Release builds
- Use incremental builds during development

### App Size Optimization

Current app size: ~2-3 MB (very small!)

To further optimize:
- Strip debug symbols in Release builds
- Enable dead code stripping
- Compress assets if any

## Support

For build-related issues:
- Check Xcode build logs
- Review Apple Developer documentation
- Search Stack Overflow
- Open an issue on GitHub

---

**Last Updated**: January 10, 2026
**For Version**: 2026.1.1
