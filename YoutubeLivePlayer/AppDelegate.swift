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
        YtDlpInstaller.shared.ensureInstalled { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.menuBarManager = MenuBarManager(audioManager: AudioPlaybackManager.shared)
                }
            }
        }
    }
}
