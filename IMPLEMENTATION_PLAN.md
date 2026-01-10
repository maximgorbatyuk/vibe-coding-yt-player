# Implementation Plan: VibeCodingYTPlayer

## Overview
macOS menu bar application to play audio from YouTube live streams with minimal external dependencies.

---

## Phase 1: Project Setup & Architecture
- [ ] Create/verify Xcode project structure for macOS menu bar app
- [ ] Set up app name: "VibeCodingYTPlayer"
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

## Phase 5: Audio Playback Engine ✅
- [x] Research and choose audio extraction method (AVPlayer/AVFoundation, or youtube-dl alternative)
- [x] Implement YouTube live stream URL parsing
- [x] Implement audio stream extraction (audio-only, no video)
- [x] Create audio playback service/manager
- [x] Implement Play functionality
- [x] Implement Pause functionality
- [x] Implement Stop functionality
- [x] Implement Restart functionality
- [x] Implement Mute functionality
- [x] Implement Unmute functionality
- [x] Implement Toggle Audio functionality (mute/unmute toggle)
- [x] Handle playback state management
- [x] Add error handling for invalid URLs or connection issues

---

## Phase 6: Main Screen Controls ✅
- [x] Add Play button to Main screen
- [x] Add Pause button to Main screen
- [x] Add Stop button to Main screen
- [x] Add Restart button to Main screen
- [x] Add Mute button to Main screen
- [x] Add Unmute button to Main screen
- [x] Add Toggle Audio button to Main screen
- [x] Add "Open in Browser" button to Main screen
- [x] Add Quit button to Main screen
- [x] Wire all buttons to audio playback service
- [x] Implement "Open in Browser" functionality
- [x] Add visual feedback for button states (enabled/disabled/active)

---

## Phase 7: Live Stream Time Display ✅
- [x] Implement live stream time tracking
- [x] Add time display component on Main screen
- [x] Format time display appropriately (HH:MM:SS or similar)
- [x] Update time display in real-time during playback

---

## Phase 8: Menu Bar Integration ✅
- [x] Create NSStatusItem for menu bar icon
- [x] Design/add menu bar icon
- [x] Create menu bar context menu
- [x] Add "Play" option to context menu
- [x] Add "Pause" option to context menu
- [x] Add "Stop" option to context menu
- [x] Add "Restart" option to context menu
- [x] Add "Mute" option to context menu
- [x] Add "Unmute" option to context menu
- [x] Add "Toggle Audio" option to context menu
- [x] Add "Open in Browser" option to context menu
- [x] Add "Quit" option to context menu
- [x] Wire all context menu items to audio playback service
- [x] Implement menu item state updates (enable/disable based on playback state)

---

## Phase 9: Polish & Testing ✅
- [x] Test all playback controls (Play, Pause, Stop, Restart)
- [x] Test audio controls (Mute, Unmute, Toggle)
- [x] Test URL persistence across app restarts
- [x] Test menu bar context menu functionality
- [x] Test "Open in Browser" functionality
- [x] Test quit functionality from all locations
- [x] Handle edge cases (invalid URLs, network errors, stream unavailable)
- [x] Add user-friendly error messages
- [x] Test app behavior when minimized to menu bar
- [x] Verify app only appears in menu bar (not Dock)
- [x] Performance testing with live streams
- [x] Memory leak testing during extended playback

---

## Phase 10: Documentation & Release Prep ✅
- [x] Update README with usage instructions
- [x] Document version pattern (YYYY.M.N)
- [x] Create build/release process documentation
- [x] Verify all features from features.md are implemented

---

## Phase 11: Documentation & Release Prep
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
