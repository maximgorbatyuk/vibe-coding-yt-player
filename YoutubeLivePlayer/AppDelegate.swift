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
        // Initialize menu bar manager with shared audio manager
        menuBarManager = MenuBarManager(audioManager: AudioPlaybackManager.shared)
    }
}
