//
//  YoutubeLivePlayerApp.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI

@main
struct YoutubeLivePlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Note: We use AppDelegate with MenuBarManager for menu bar integration
        // This provides both context menu and window access via the status item
        Settings {
            EmptyView()
        }
    }
}
