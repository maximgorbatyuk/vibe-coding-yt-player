//
//  MenuCommands.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 10.01.2026.
//

import SwiftUI

/// Menu commands for the app
struct AppMenuCommands: View {
    @ObservedObject private var audioManager = AudioPlaybackManager.shared
    @AppStorage("youtubeURL") private var youtubeURL: String = ""

    var body: some View {
        Group {
            // Playback Controls
            Button("Play") {
                audioManager.play(urlString: youtubeURL)
            }
            .disabled(!canPlay)
            .keyboardShortcut("p", modifiers: .command)

            Button("Pause") {
                audioManager.pause()
            }
            .disabled(!canPause)

            Button("Stop") {
                audioManager.stop()
            }
            .disabled(!canStop)
            .keyboardShortcut("s", modifiers: .command)

            Button("Restart") {
                audioManager.restart()
            }
            .disabled(audioManager.currentURL.isEmpty)
            .keyboardShortcut("r", modifiers: .command)

            Divider()

            // Audio Controls
            Button("Mute") {
                audioManager.mute()
            }
            .disabled(!canMute)
            .keyboardShortcut("m", modifiers: .command)

            Button("Unmute") {
                audioManager.unmute()
            }
            .disabled(!canUnmute)

            Button(audioManager.isMuted ? "Toggle Audio (Unmute)" : "Toggle Audio (Mute)") {
                audioManager.toggleMute()
            }
            .disabled(!audioManager.playbackState.isPlaying)
            .keyboardShortcut("t", modifiers: .command)

            Divider()

            // Additional Actions
            Button("Open in Browser") {
                openInBrowser()
            }
            .disabled(!canOpenInBrowser)
            .keyboardShortcut("b", modifiers: .command)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }

    // MARK: - Computed Properties

    private var canPlay: Bool {
        audioManager.playbackState.canPlay && !youtubeURL.isEmpty
    }

    private var canPause: Bool {
        audioManager.playbackState.canPause
    }

    private var canStop: Bool {
        audioManager.playbackState.canStop
    }

    private var canMute: Bool {
        !audioManager.isMuted && audioManager.playbackState.isPlaying
    }

    private var canUnmute: Bool {
        audioManager.isMuted && audioManager.playbackState.isPlaying
    }

    private var canOpenInBrowser: Bool {
        !youtubeURL.isEmpty && URLValidator.isValidYouTubeURL(youtubeURL)
    }

    // MARK: - Actions

    private func openInBrowser() {
        guard !youtubeURL.isEmpty, let url = URL(string: youtubeURL) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
