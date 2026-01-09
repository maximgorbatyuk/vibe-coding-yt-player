# Implementation Plan: Youtube Live Player

## Overview
macOS menu bar application to play audio from YouTube live streams with minimal external dependencies.

---

## Phase 1: Project Setup & Architecture
- [ ] Create/verify Xcode project structure for macOS menu bar app
- [ ] Set up app name: "Youtube Live Player"
- [ ] Configure initial version: 2026.1.1
- [ ] Set up project to run as menu bar app (LSUIElement = YES)
- [ ] Configure app to use English as single language
- [ ] Review and minimize external dependencies (prefer native frameworks)
- [ ] Set up basic project structure with necessary groups/folders

---

## Phase 2: Core UI Structure
- [ ] Create tab view container to switch between screens
- [ ] Create Main screen view
- [ ] Create Settings screen view
- [ ] Implement tab navigation between Main and Settings screens
- [ ] Set up basic layout constraints/SwiftUI structure

---

## Phase 3: Settings Screen Implementation
- [ ] Add app version display on Settings screen (format: YYYY.M.N)
- [ ] Add quit button on Settings screen
- [ ] Implement quit functionality
- [ ] Add input field/section for YouTube live stream URL (if needed)
- [ ] Style Settings screen according to macOS design guidelines

---

## Phase 4: User Defaults & URL Management
- [ ] Set up UserDefaults keys for storing YouTube URL
- [ ] Implement save functionality for last used YouTube URL
- [ ] Implement load functionality to retrieve saved URL on app launch
- [ ] Add URL validation (basic YouTube URL format check)

---

## Phase 5: Audio Playback Engine
- [ ] Research and choose audio extraction method (AVPlayer/AVFoundation, or youtube-dl alternative)
- [ ] Implement YouTube live stream URL parsing
- [ ] Implement audio stream extraction (audio-only, no video)
- [ ] Create audio playback service/manager
- [ ] Implement Play functionality
- [ ] Implement Pause functionality
- [ ] Implement Stop functionality
- [ ] Implement Restart functionality
- [ ] Implement Mute functionality
- [ ] Implement Unmute functionality
- [ ] Implement Toggle Audio functionality (mute/unmute toggle)
- [ ] Handle playback state management
- [ ] Add error handling for invalid URLs or connection issues

---

## Phase 6: Main Screen Controls
- [ ] Add Play button to Main screen
- [ ] Add Pause button to Main screen
- [ ] Add Stop button to Main screen
- [ ] Add Restart button to Main screen
- [ ] Add Mute button to Main screen
- [ ] Add Unmute button to Main screen
- [ ] Add Toggle Audio button to Main screen
- [ ] Add "Open in Browser" button to Main screen
- [ ] Add Quit button to Main screen
- [ ] Wire all buttons to audio playback service
- [ ] Implement "Open in Browser" functionality
- [ ] Add visual feedback for button states (enabled/disabled/active)

---

## Phase 7: Live Stream Time Display
- [ ] Implement live stream time tracking
- [ ] Add time display component on Main screen
- [ ] Format time display appropriately (HH:MM:SS or similar)
- [ ] Update time display in real-time during playback

---

## Phase 8: Menu Bar Integration
- [ ] Create NSStatusItem for menu bar icon
- [ ] Design/add menu bar icon
- [ ] Create menu bar context menu
- [ ] Add "Play" option to context menu
- [ ] Add "Pause" option to context menu
- [ ] Add "Stop" option to context menu
- [ ] Add "Restart" option to context menu
- [ ] Add "Mute" option to context menu
- [ ] Add "Unmute" option to context menu
- [ ] Add "Toggle Audio" option to context menu
- [ ] Add "Open in Browser" option to context menu
- [ ] Add "Quit" option to context menu
- [ ] Wire all context menu items to audio playback service
- [ ] Implement menu item state updates (enable/disable based on playback state)

---

## Phase 9: Polish & Testing
- [ ] Test all playback controls (Play, Pause, Stop, Restart)
- [ ] Test audio controls (Mute, Unmute, Toggle)
- [ ] Test URL persistence across app restarts
- [ ] Test menu bar context menu functionality
- [ ] Test "Open in Browser" functionality
- [ ] Test quit functionality from all locations
- [ ] Handle edge cases (invalid URLs, network errors, stream unavailable)
- [ ] Add user-friendly error messages
- [ ] Test app behavior when minimized to menu bar
- [ ] Verify app only appears in menu bar (not Dock)
- [ ] Performance testing with live streams
- [ ] Memory leak testing during extended playback

---

## Phase 10: Documentation & Release Prep
- [ ] Update README with usage instructions
- [ ] Document version pattern (YYYY.M.N)
- [ ] Add screenshots/demo if needed
- [ ] Create build/release process documentation
- [ ] Verify all features from features.md are implemented
- [ ] Final code review and cleanup
- [ ] Prepare for release 2026.1.1

---

## Technical Considerations
- **Audio Extraction**: Need to determine best approach for extracting audio from YouTube live streams without external dependencies
- **Minimal Dependencies**: Prefer AVFoundation and native macOS frameworks
- **Menu Bar App**: Use NSStatusItem and configure LSUIElement properly
- **YouTube API**: May need to handle YouTube's streaming protocols (HLS, DASH)
- **Real-time Updates**: Consider using Combine or async/await for state management

---

## Success Criteria
✓ All checkboxes in features.md are completed
✓ App runs as menu bar application
✓ Audio playback works with YouTube live streams
✓ All controls work from both UI and context menu
✓ URL persistence works correctly
✓ App is stable and handles errors gracefully
