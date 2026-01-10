//
//  MainView.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI
import AppKit

struct MainView: View {
    @ObservedObject private var audioManager = AudioPlaybackManager.shared
    @AppStorage("youtubeURL") private var youtubeURL: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Main Screen")
                .font(.title)
                .padding(.top)

            // URL Display Section
            VStack(spacing: 8) {
                if !youtubeURL.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current URL:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(youtubeURL)
                            .font(.caption)
                            .lineLimit(2)
                            .truncationMode(.middle)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                } else {
                    Text("No URL set. Go to Settings to add a YouTube URL.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }

            // Playback State Indicator
            PlaybackStateView(state: audioManager.playbackState, isMuted: audioManager.isMuted)

            // Time Display
            TimeDisplayView(elapsedTime: audioManager.elapsedTime, playbackState: audioManager.playbackState)

            // Error Display
            if let errorMessage = audioManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                    .padding(.horizontal)
            }

            // Playback Controls Section
            VStack(spacing: 16) {
                Text("Playback Controls")
                    .font(.headline)

                // Play, Pause, Stop, Restart
                HStack(spacing: 12) {
                    ControlButton(
                        title: "Play",
                        icon: "play.fill",
                        color: .green,
                        isEnabled: audioManager.playbackState.canPlay && !youtubeURL.isEmpty
                    ) {
                        audioManager.play(urlString: youtubeURL)
                    }

                    ControlButton(
                        title: "Pause",
                        icon: "pause.fill",
                        color: .orange,
                        isEnabled: audioManager.playbackState.canPause
                    ) {
                        audioManager.pause()
                    }

                    ControlButton(
                        title: "Stop",
                        icon: "stop.fill",
                        color: .red,
                        isEnabled: audioManager.playbackState.canStop
                    ) {
                        audioManager.stop()
                    }

                    ControlButton(
                        title: "Restart",
                        icon: "arrow.clockwise",
                        color: .blue,
                        isEnabled: !audioManager.currentURL.isEmpty
                    ) {
                        audioManager.restart()
                    }
                }
            }
            .padding(.horizontal)

            // Audio Controls Section
            VStack(spacing: 16) {
                Text("Audio Controls")
                    .font(.headline)

                HStack(spacing: 12) {
                    ControlButton(
                        title: "Mute",
                        icon: "speaker.slash.fill",
                        color: .gray,
                        isEnabled: !audioManager.isMuted && audioManager.playbackState.isPlaying
                    ) {
                        audioManager.mute()
                    }

                    ControlButton(
                        title: "Unmute",
                        icon: "speaker.wave.2.fill",
                        color: .blue,
                        isEnabled: audioManager.isMuted && audioManager.playbackState.isPlaying
                    ) {
                        audioManager.unmute()
                    }

                    ControlButton(
                        title: "Toggle Audio",
                        icon: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                        color: .purple,
                        isEnabled: audioManager.playbackState.isPlaying
                    ) {
                        audioManager.toggleMute()
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // Additional Actions
            VStack(spacing: 12) {
                Button(action: openInBrowser) {
                    Label("Open in Browser", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(youtubeURL.isEmpty || !URLValidator.isValidYouTubeURL(youtubeURL))
                .tint(.blue)

                Button(action: quitApp) {
                    Label("Quit App", systemImage: "power")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(minWidth: 300, minHeight: 400)
        .padding()
    }

    private func openInBrowser() {
        guard !youtubeURL.isEmpty,
              let url = URL(string: youtubeURL) else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Control Button Component

struct ControlButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption2)
            }
            .frame(width: 70, height: 60)
        }
        .buttonStyle(.bordered)
        .tint(color)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Playback State View

struct PlaybackStateView: View {
    let state: AudioPlaybackManager.PlaybackState
    let isMuted: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: stateIcon)
                .foregroundColor(stateColor)
                .imageScale(.large)

            Text(stateText)
                .font(.headline)
                .foregroundColor(stateColor)

            if isMuted && state.isPlaying {
                Image(systemName: "speaker.slash.fill")
                    .foregroundColor(.orange)
                    .imageScale(.small)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(stateColor.opacity(0.1))
        )
    }

    private var stateText: String {
        switch state {
        case .stopped:
            return "Stopped"
        case .loading:
            return "Loading..."
        case .playing:
            return "Playing"
        case .paused:
            return "Paused"
        case .error:
            return "Error"
        }
    }

    private var stateIcon: String {
        switch state {
        case .stopped:
            return "stop.circle"
        case .loading:
            return "arrow.clockwise.circle"
        case .playing:
            return "play.circle.fill"
        case .paused:
            return "pause.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    private var stateColor: Color {
        switch state {
        case .stopped:
            return .gray
        case .loading:
            return .blue
        case .playing:
            return .green
        case .paused:
            return .orange
        case .error:
            return .red
        }
    }
}

// MARK: - Time Display View

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

#Preview {
    MainView()
}
