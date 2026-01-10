//
//  MenuBarManager.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 10.01.2026.
//

import AppKit
import Combine
import Foundation
import SwiftUI

/// Manages the menu bar icon and context menu
class MenuBarManager: NSObject {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private let audioManager: AudioPlaybackManager
    private var cancellables = Set<AnyCancellable>()
    private var popover: NSPopover?

    // Menu items that need state updates
    private var playMenuItem: NSMenuItem?
    private var pauseMenuItem: NSMenuItem?
    private var stopMenuItem: NSMenuItem?
    private var restartMenuItem: NSMenuItem?
    private var muteMenuItem: NSMenuItem?
    private var unmuteMenuItem: NSMenuItem?
    private var toggleAudioMenuItem: NSMenuItem?
    private var openInBrowserMenuItem: NSMenuItem?

    // MARK: - Initialization

    init(audioManager: AudioPlaybackManager) {
        self.audioManager = audioManager
        super.init()
        setupStatusItem()
        setupObservers()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "music.note.list", accessibilityDescription: "Youtube Live Player")
            button.target = self
            button.action = #selector(togglePopover)
        }

        updateMenu()
        setupPopover()
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    private func setupObservers() {
        // Observe playback state changes
        audioManager.$playbackState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_: AudioPlaybackManager.PlaybackState) in
                self?.updateMenuItemStates()
            }
            .store(in: &cancellables)

        // Observe mute state changes
        audioManager.$isMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_: Bool) in
                self?.updateMenuItemStates()
            }
            .store(in: &cancellables)

        // Observe current URL changes
        audioManager.$currentURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_: String) in
                self?.updateMenuItemStates()
            }
            .store(in: &cancellables)
    }

    // MARK: - Menu Creation

    private func updateMenu() {
        let menu = NSMenu()

        // App title
        let titleItem = NSMenuItem(title: "Youtube Live Player", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // Playback Controls Section
        let playbackHeader = NSMenuItem(title: "Playback Controls", action: nil, keyEquivalent: "")
        playbackHeader.isEnabled = false
        menu.addItem(playbackHeader)

        playMenuItem = createMenuItem(title: "Play", action: #selector(playAction), key: "p")
        menu.addItem(playMenuItem!)

        pauseMenuItem = createMenuItem(title: "Pause", action: #selector(pauseAction), key: "")
        menu.addItem(pauseMenuItem!)

        stopMenuItem = createMenuItem(title: "Stop", action: #selector(stopAction), key: "s")
        menu.addItem(stopMenuItem!)

        restartMenuItem = createMenuItem(title: "Restart", action: #selector(restartAction), key: "r")
        menu.addItem(restartMenuItem!)

        menu.addItem(NSMenuItem.separator())

        // Audio Controls Section
        let audioHeader = NSMenuItem(title: "Audio Controls", action: nil, keyEquivalent: "")
        audioHeader.isEnabled = false
        menu.addItem(audioHeader)

        muteMenuItem = createMenuItem(title: "Mute", action: #selector(muteAction), key: "m")
        menu.addItem(muteMenuItem!)

        unmuteMenuItem = createMenuItem(title: "Unmute", action: #selector(unmuteAction), key: "")
        menu.addItem(unmuteMenuItem!)

        toggleAudioMenuItem = createMenuItem(title: "Toggle Audio", action: #selector(toggleAudioAction), key: "t")
        menu.addItem(toggleAudioMenuItem!)

        menu.addItem(NSMenuItem.separator())

        // Additional Actions
        openInBrowserMenuItem = createMenuItem(title: "Open in Browser", action: #selector(openInBrowserAction), key: "b")
        menu.addItem(openInBrowserMenuItem!)

        menu.addItem(NSMenuItem.separator())

        // Show Window option (for accessing full UI via menu)
        let showWindowItem = createMenuItem(title: "Show Window", action: #selector(togglePopover), key: "w")
        menu.addItem(showWindowItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = createMenuItem(title: "Quit", action: #selector(quitAction), key: "q")
        menu.addItem(quitItem)

        // Important: Set the menu but also allow click action
        // Note: In macOS, setting a menu makes the item show menu on click
        // To show popover, users can use the keyboard shortcut or menu item
        statusItem?.menu = menu
        updateMenuItemStates()
    }

    private func createMenuItem(title: String, action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    // MARK: - Menu Item State Updates

    private func updateMenuItemStates() {
        let state = audioManager.playbackState
        let youtubeURL = UserDefaults.standard.string(forKey: "youtubeURL") ?? ""

        // Playback controls
        playMenuItem?.isEnabled = state.canPlay && !youtubeURL.isEmpty
        pauseMenuItem?.isEnabled = state.canPause
        stopMenuItem?.isEnabled = state.canStop
        restartMenuItem?.isEnabled = !audioManager.currentURL.isEmpty

        // Audio controls
        muteMenuItem?.isEnabled = !audioManager.isMuted && state.isPlaying
        unmuteMenuItem?.isEnabled = audioManager.isMuted && state.isPlaying
        toggleAudioMenuItem?.isEnabled = state.isPlaying

        // Update toggle audio title based on current state
        if let toggleItem = toggleAudioMenuItem {
            toggleItem.title = audioManager.isMuted ? "Toggle Audio (Unmute)" : "Toggle Audio (Mute)"
        }

        // Open in Browser
        openInBrowserMenuItem?.isEnabled = !youtubeURL.isEmpty && URLValidator.isValidYouTubeURL(youtubeURL)
    }

    // MARK: - Actions

    @objc private func playAction() {
        let youtubeURL = UserDefaults.standard.string(forKey: "youtubeURL") ?? ""
        audioManager.play(urlString: youtubeURL)
    }

    @objc private func pauseAction() {
        audioManager.pause()
    }

    @objc private func stopAction() {
        audioManager.stop()
    }

    @objc private func restartAction() {
        audioManager.restart()
    }

    @objc private func muteAction() {
        audioManager.mute()
    }

    @objc private func unmuteAction() {
        audioManager.unmute()
    }

    @objc private func toggleAudioAction() {
        audioManager.toggleMute()
    }

    @objc private func openInBrowserAction() {
        let youtubeURL = UserDefaults.standard.string(forKey: "youtubeURL") ?? ""
        guard !youtubeURL.isEmpty, let url = URL(string: youtubeURL) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
