//
//  AppDelegate.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 10.01.2026.
//

import AppKit
import SwiftUI

/// App delegate to manage menu bar integration
class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarManager: MenuBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !YtDlpInstaller.shared.isYtDlpInstalled() {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "yt-dlp Required"
                alert.informativeText = "VibeCodingYTPlayer requires yt-dlp to extract audio from YouTube.\n\nPlease install it using Homebrew by running the following command in Terminal:\n\nbrew install yt-dlp"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")

                let response = alert.runModal()

                if response == .alertFirstButtonReturn {
                    NSApplication.shared.terminate(nil)
                }
            }
            return
        }

        menuBarManager = MenuBarManager(audioManager: AudioPlaybackManager.shared)
    }
}
