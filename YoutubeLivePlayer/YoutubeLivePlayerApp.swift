//
//  YoutubeLivePlayerApp.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI

@main
struct YoutubeLivePlayerApp: App {
    var body: some Scene {
        // Menu bar app with window support
        MenuBarExtra("Youtube Live Player", systemImage: "music.note.list") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
