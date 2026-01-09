# Phase 7 Implementation Summary: Live Stream Time Display

## Overview
Phase 7 implements real-time elapsed time tracking and display for audio playback. This phase adds a visual timer that shows how long the user has been listening to the live stream, with accurate tracking across play, pause, stop, and restart operations.

## Implementation Date
January 9, 2026

## Key Components

### 1. AudioPlaybackManager Time Tracking
**Location**: `YoutubeLivePlayer/Services/AudioPlaybackManager.swift`

#### New Published Properties

```swift
@Published var elapsedTime: TimeInterval = 0
```

**Purpose**: Reactive property that updates the UI automatically when time changes
- Published every 0.1 seconds during playback
- Accessible to SwiftUI views via Combine
- Represents total elapsed time in seconds

#### New Private Properties

```swift
private var playbackTimer: Timer?
private var playbackStartTime: Date?
private var accumulatedTime: TimeInterval = 0
```

**Purpose**: Internal time tracking state
- `playbackTimer`: Scheduled timer that fires every 0.1 seconds
- `playbackStartTime`: Timestamp when playback started (or resumed)
- `accumulatedTime`: Time accumulated before current play session (used for pause/resume)

### 2. Timer Management System

#### Start Timer
```swift
private func startTimer() {
    stopTimer() // Stop any existing timer
    playbackStartTime = Date()

    playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
        self?.updateElapsedTime()
    }
}
```

**Behavior**:
- Called when playback begins or resumes
- Resets start time to current moment
- Creates repeating timer (0.1 second interval for smooth updates)
- Uses weak self to prevent retain cycles

**Integration Points**:
- `startPlayback()`: Called after AVPlayer starts playing
- `resume()`: Called when resuming from pause

#### Pause Timer
```swift
private func pauseTimer() {
    if let startTime = playbackStartTime {
        accumulatedTime += Date().timeIntervalSince(startTime)
    }
    stopTimer()
}
```

**Behavior**:
- Called when playback is paused
- Accumulates elapsed time since last start
- Preserves total elapsed time for resume
- Stops the timer but doesn't reset accumulated time

**Key Feature**: Maintains time across pause/resume cycles
- First play: 00:00 → 01:30 (user pauses)
- Accumulated: 90 seconds
- Resume: Continues from 01:30, not 00:00

**Integration Points**:
- `pause()`: Called when user pauses playback

#### Stop Timer
```swift
private func stopTimer() {
    playbackTimer?.invalidate()
    playbackTimer = nil
    playbackStartTime = nil
}
```

**Behavior**:
- Invalidates and removes the timer
- Clears start time reference
- Doesn't reset accumulated time (that's done separately)

**Integration Points**:
- `pauseTimer()`: Clean up timer after accumulating time
- `deinit`: Cleanup on object deallocation
- `cleanup()`: Called during stop/error states

#### Reset Timer
```swift
private func resetTimer() {
    accumulatedTime = 0
    elapsedTime = 0
}
```

**Behavior**:
- Clears all time tracking state
- Resets both internal and published time to zero
- Called when completely stopping or restarting playback

**Integration Points**:
- `stop()`: Reset time when user stops playback
- `setError()`: Reset time on error states

#### Update Elapsed Time
```swift
private func updateElapsedTime() {
    guard let startTime = playbackStartTime else { return }
    elapsedTime = accumulatedTime + Date().timeIntervalSince(startTime)
}
```

**Behavior**:
- Called by timer every 0.1 seconds
- Calculates total time: accumulated + current session
- Updates published property (triggers UI update)

**Formula**:
```
Total Time = Accumulated Time + (Current Time - Start Time)
```

**Example Timeline**:
1. Play at 10:00:00 → startTime = 10:00:00, accumulated = 0
2. At 10:01:30 → elapsed = 0 + 90s = 90s (01:30)
3. Pause at 10:01:30 → accumulated = 90s, stop timer
4. Resume at 10:05:00 → startTime = 10:05:00, accumulated = 90s
5. At 10:05:45 → elapsed = 90s + 45s = 135s (02:15)

### 3. Time Formatting Utility

```swift
static func formatTime(_ timeInterval: TimeInterval) -> String {
    let totalSeconds = Int(timeInterval)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
```

**Behavior**:
- Static method (can be called without instance)
- Converts TimeInterval (seconds) to readable format
- Adaptive format:
  - Less than 1 hour: "MM:SS" (e.g., "05:42")
  - 1 hour or more: "HH:MM:SS" (e.g., "02:15:30")
- Zero-padded for consistent width

**Examples**:
- 0 seconds → "00:00"
- 42 seconds → "00:42"
- 125 seconds → "02:05"
- 3661 seconds → "01:01:01"
- 7325 seconds → "02:02:05"

**Design Decision**: Adaptive format
- Short streams don't waste space with "00:00:42"
- Long streams show hours when needed
- Familiar format (like YouTube, media players)

### 4. TimeDisplayView Component
**Location**: `YoutubeLivePlayer/Views/MainView.swift`

```swift
struct TimeDisplayView: View {
    let elapsedTime: TimeInterval
    let playbackState: AudioPlaybackManager.PlaybackState

    var body: some View {
        if shouldShowTime {
            VStack(spacing: 4) {
                Text("Elapsed Time")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(AudioPlaybackManager.formatTime(elapsedTime))
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.1))
            )
        }
    }

    private var shouldShowTime: Bool {
        switch playbackState {
        case .playing, .paused:
            return true
        case .stopped, .loading, .error:
            return false
        }
    }
}
```

#### Visual Design

**Layout**:
- Vertical stack with label and time
- Label: "Elapsed Time" (caption2, secondary color)
- Time: Large monospaced font (title2, semibold, primary color)
- Rounded rectangle background (subtle gray)
- Padding for breathing room

**Typography Choices**:
- **Monospaced font**: All digits same width
  - Prevents layout shift when digits change
  - Professional, timer-like appearance
  - "00:00" and "99:99" take same space
- **Title2 size**: Large enough to read at a glance
- **Semibold weight**: Prominent but not overwhelming

**Color Scheme**:
- Label: Secondary (system gray, adapts to dark mode)
- Time: Primary (black in light mode, white in dark mode)
- Background: Secondary with 10% opacity (subtle separation)

#### Conditional Display Logic

```swift
private var shouldShowTime: Bool {
    switch playbackState {
    case .playing, .paused:
        return true
    case .stopped, .loading, .error:
        return false
    }
}
```

**Display Rules**:
- ✅ **Show** when: Playing or Paused
- ❌ **Hide** when: Stopped, Loading, or Error

**Rationale**:
- **Playing**: User needs to see elapsed time
- **Paused**: Time frozen but still relevant (shows where paused)
- **Stopped**: No active session, time reset, nothing to show
- **Loading**: Haven't started yet, no time elapsed
- **Error**: Failed playback, time not meaningful

**User Experience**:
1. User clicks Play → Loading state (no time shown)
2. Playback starts → Playing state (time appears: "00:00")
3. Time counts up → "00:01", "00:02", etc.
4. User pauses → Paused state (time freezes, stays visible)
5. User resumes → Playing state (time continues from where paused)
6. User stops → Stopped state (time disappears)

### 5. Integration with MainView

**Placement**: Between playback state indicator and error display

```swift
// Playback State Indicator
PlaybackStateView(state: audioManager.playbackState, isMuted: audioManager.isMuted)

// Time Display
TimeDisplayView(elapsedTime: audioManager.elapsedTime, playbackState: audioManager.playbackState)

// Error Display
if let errorMessage = audioManager.errorMessage {
    // ...
}
```

**Visual Hierarchy**:
1. URL display (top)
2. Playback state (playing/paused/stopped)
3. **Time display** (how long playing)
4. Error messages (if any)
5. Control buttons (middle)
6. Actions (bottom)

**Design Rationale**:
- Time closely associated with playback state
- Both show current status
- Logical flow: State → Duration → Controls

## Technical Implementation Details

### Timer Precision

**Update Interval**: 0.1 seconds (100ms)

**Trade-offs**:
- ✅ Smooth updates (10 times per second)
- ✅ Low CPU usage (not every frame)
- ✅ Accurate enough for user perception
- ❌ Not frame-perfect (acceptable for time display)

**Alternatives Considered**:
- 1.0 second updates: ❌ Too slow, visible "ticking"
- 0.01 second updates: ❌ Unnecessary CPU load
- DisplayLink (60fps): ❌ Overkill for time display

### Pause/Resume Accuracy

**Accumulation Strategy**:
```swift
accumulatedTime += Date().timeIntervalSince(startTime)
```

**Benefits**:
- No time lost during pause
- Accurate across multiple pause/resume cycles
- Simple calculation on resume

**Example Scenario**:
```
Play 00:00 → 01:00 (60s)
Pause (accumulated: 60s)
Resume → Play 00:30 (30s more)
Pause (accumulated: 90s)
Resume → Play 00:15 (15s more)
Total: 01:45 (105s) ✓ Accurate
```

### Memory Management

**Weak References**:
```swift
playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
    self?.updateElapsedTime()
}
```

**Purpose**: Prevent retain cycles
- Timer holds reference to closure
- Closure could hold reference to self
- Weak self breaks the cycle
- Timer can be invalidated and released

**Cleanup**:
- `deinit`: Calls `stopTimer()` to cleanup
- Timer invalidated when object deallocates
- No leaks even if player is released during playback

### State Synchronization

**Reactive Updates**:
- Timer updates `elapsedTime` (Published property)
- SwiftUI observes changes via `@Published`
- UI updates automatically (no manual refresh)
- Changes propagate instantly to TimeDisplayView

**Thread Safety**:
- Timer fires on main thread (RunLoop default)
- All UI updates happen on main thread
- No race conditions or thread synchronization needed

## Design Decisions

### 1. Why Elapsed Time vs Remaining Time?

**Decision**: Show elapsed time only

**Rationale**:
- ✅ Live streams have no end time (infinite duration)
- ✅ Remaining time is meaningless for live content
- ✅ Users want to know "how long have I been listening"
- ✅ Matches expectations for live stream players

**Alternative Rejected**: Remaining time
- ❌ Not applicable to live streams
- ❌ Would require total duration (unavailable)
- ❌ Confusing for continuous content

### 2. Why Hide Time When Stopped?

**Decision**: Conditionally show/hide based on playback state

**Rationale**:
- ✅ Stopped = no active session, nothing to display
- ✅ Reduces visual clutter when not relevant
- ✅ Clear indication that playback has ended
- ✅ Automatic reset on next play

**Alternative Considered**: Always show time (frozen at last value)
- ❌ Could confuse users (looks like still playing)
- ❌ Stale data after stop
- ❌ Extra visual element when not needed

### 3. Why Show Time When Paused?

**Decision**: Keep time visible during pause

**Rationale**:
- ✅ Shows where user paused (useful information)
- ✅ Confirms pause worked (time frozen)
- ✅ Provides context for resume decision
- ✅ Standard behavior in media players

**Example Use Case**: User pauses at 15:30, takes a break, comes back later and sees they're at 15:30 (knows where to resume)

### 4. Why Monospaced Font?

**Decision**: Use system monospaced font for time display

**Rationale**:
- ✅ Fixed-width digits prevent layout shift
- ✅ Professional timer appearance
- ✅ Easier to read changing numbers
- ✅ Standard for time/code displays

**Without Monospaced**:
- ❌ "1" narrower than "8" causes jumping
- ❌ "00:00" → "11:11" changes width
- ❌ Distracting visual movement

**With Monospaced**:
- ✅ All digits same width
- ✅ Stable layout during counting
- ✅ Smooth, professional appearance

### 5. Why 0.1 Second Updates?

**Decision**: Update timer 10 times per second

**Rationale**:
- ✅ Smooth appearance (no visible ticking)
- ✅ Low CPU usage (efficient)
- ✅ Accurate enough (users see 1-second increments)
- ✅ Responsive to pause/stop actions

**User Perception**:
- Displays whole seconds (00:01, 00:02)
- But updates 10x per second internally
- Ensures second changes precisely when they occur
- No delays or missed seconds

## User Workflows

### Basic Playback with Time Display

1. **User clicks Play**
   - State: Stopped → Loading
   - Time display: Hidden (loading)
   - Timer: Not started yet

2. **Playback begins**
   - State: Loading → Playing
   - Time display: Appears showing "00:00"
   - Timer: Starts, begins counting

3. **Time counts up**
   - Updates every 0.1 seconds
   - Display updates: "00:01", "00:02", "00:03"...
   - Smooth continuous counting

4. **User pauses at 02:30**
   - State: Playing → Paused
   - Time display: Stays visible, frozen at "02:30"
   - Timer: Pauses, accumulates 150 seconds

5. **User resumes**
   - State: Paused → Playing
   - Time display: Continues from "02:30"
   - Timer: Resumes counting from accumulated time

6. **User stops**
   - State: Playing → Stopped
   - Time display: Disappears
   - Timer: Stops and resets to zero

### Restart Workflow

1. **Playing at 05:00**
   - State: Playing
   - Time display: "05:00"
   - Accumulated: 300 seconds

2. **User clicks Restart**
   - Stops current playback
   - Time resets to zero
   - Re-extracts stream URL
   - Starts fresh playback

3. **New playback begins**
   - State: Loading → Playing
   - Time display: "00:00" (fresh start)
   - Timer: New session, no accumulated time

### Error Recovery

1. **Playing at 03:45**
   - State: Playing
   - Time: "03:45"

2. **Network error occurs**
   - State: Playing → Error
   - Time display: Disappears
   - Timer: Stops and resets

3. **User retries**
   - Clicks Play again
   - State: Error → Loading → Playing
   - Time: Starts from "00:00" (new session)

## Testing Recommendations

### Manual Testing Checklist

**Basic Time Display**:
- [ ] Start playback, verify time appears at "00:00"
- [ ] Verify time counts up continuously (no jumps or freezes)
- [ ] Verify monospaced font (digits don't cause width changes)
- [ ] Verify time format shows MM:SS for times under 1 hour
- [ ] Play for over 1 hour, verify format changes to HH:MM:SS

**Pause/Resume**:
- [ ] Play to 00:30, pause, verify time freezes at "00:30"
- [ ] Verify time stays visible while paused
- [ ] Resume, verify time continues from "00:30" not "00:00"
- [ ] Pause multiple times, verify accumulated time is accurate

**Stop/Restart**:
- [ ] Play to 01:00, stop, verify time disappears
- [ ] Play again, verify time starts from "00:00"
- [ ] Play to 02:00, restart, verify time resets to "00:00"

**State Transitions**:
- [ ] Verify time hidden during Loading state
- [ ] Verify time hidden during Stopped state
- [ ] Verify time hidden during Error state
- [ ] Verify time visible during Playing state
- [ ] Verify time visible during Paused state

**Accuracy**:
- [ ] Use stopwatch to verify elapsed time accuracy
- [ ] Pause for known period, verify time doesn't advance
- [ ] Multiple pause/resume cycles, verify total time correct

**Edge Cases**:
- [ ] Very short playback (< 10 seconds)
- [ ] Long playback (> 1 hour, verify HH:MM:SS format)
- [ ] Rapid pause/resume clicking
- [ ] Stop immediately after play
- [ ] Network error during playback (verify time resets)

## Known Limitations

1. **No Seek/Scrubbing**
   - Can't jump to specific time
   - Live streams are real-time only
   - Future enhancement: Allow seeking in buffered content

2. **No Total Duration**
   - Live streams have no end
   - Can't show "total length"
   - Elapsed time only

3. **No Playback Speed Control**
   - Normal speed only (1.0x)
   - Could add speed controls in future
   - Live streams typically played at normal speed

4. **Timer Resolution**
   - 0.1 second updates (not millisecond precision)
   - Sufficient for user display
   - Not suitable for precise measurements

5. **No Time Persistence**
   - Time resets on app restart
   - Could save last session time to UserDefaults
   - Current behavior: Fresh start each launch

## Files Modified/Created

### Modified Files
- `YoutubeLivePlayer/Services/AudioPlaybackManager.swift`
  - Added: `elapsedTime` published property
  - Added: Timer management (start, pause, stop, reset)
  - Added: Time formatting utility
  - Added: Integration with playback state changes

- `YoutubeLivePlayer/Views/MainView.swift`
  - Added: TimeDisplayView component
  - Added: Time display integration
  - Updated: Layout to include time display

- `IMPLEMENTATION_PLAN.md`
  - Marked Phase 7 as complete

### New Components
- `TimeDisplayView`: Reusable time display component

## Integration Points

### Phase 5 Integration (AudioPlaybackManager)
- Time tracking integrated with existing playback controls
- Timer starts/stops with AVPlayer state
- Uses existing state machine (PlaybackState enum)

### Phase 6 Integration (MainView)
- Time display positioned logically with state indicator
- Uses same reactive pattern (@Published properties)
- Consistent visual design with other components

### Phase 8 Preview (Menu Bar)
- formatTime() static method can be reused
- elapsedTime can be shown in menu bar tooltip
- Timer state available for menu item updates

## Features from features.md

Checking off completed features:

**Main Screen**:
- [x] Show the current time of the live stream ✅ (shows elapsed time)

**Note**: The feature specifies "current time of the live stream" which we interpret as elapsed playback time, since:
- Live streams don't have a "current time" in the traditional sense (no start/end)
- Users want to know how long they've been listening
- Standard interpretation for live stream players

## Conclusion

Phase 7 successfully implements comprehensive time tracking with:

- ✅ Accurate elapsed time tracking
- ✅ Real-time display updates (10 times per second)
- ✅ Pause/resume support with time preservation
- ✅ Smart formatting (MM:SS and HH:MM:SS)
- ✅ Conditional display based on playback state
- ✅ Monospaced font for stable layout
- ✅ Memory-safe timer management
- ✅ Seamless integration with existing architecture
- ✅ Professional, polished appearance

The implementation provides users with clear feedback about their listening session duration, enhancing the overall user experience and completing all main screen requirements from the feature list.

**Build Status**: ✅ Successful
**All Phase 7 Requirements**: ✅ Complete
**Ready for**: Phase 8 (Menu Bar Integration)
