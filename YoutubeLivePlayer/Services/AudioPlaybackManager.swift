//
//  AudioPlaybackManager.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import Foundation
import AVFoundation
import Combine

/// Manages audio playback from YouTube live streams
/// Uses yt-dlp to extract audio stream URLs and AVPlayer for playback
class AudioPlaybackManager: ObservableObject {
    // MARK: - Shared Instance

    static let shared = AudioPlaybackManager()

    // MARK: - Published Properties

    @Published var playbackState: PlaybackState = .stopped
    @Published var isMuted: Bool = false
    @Published var errorMessage: String?
    @Published var currentURL: String = ""
    @Published var elapsedTime: TimeInterval = 0

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var playerObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()
    private var playbackTimer: Timer?
    private var playbackStartTime: Date?
    private var accumulatedTime: TimeInterval = 0

    // MARK: - Playback State

    enum PlaybackState: Equatable {
        case stopped
        case loading
        case playing
        case paused
        case error(String)

        var isPlaying: Bool {
            if case .playing = self { return true }
            return false
        }

        var canPlay: Bool {
            switch self {
            case .stopped, .paused, .error:
                return true
            case .loading, .playing:
                return false
            }
        }

        var canPause: Bool {
            if case .playing = self { return true }
            return false
        }

        var canStop: Bool {
            switch self {
            case .playing, .paused, .loading:
                return true
            case .stopped, .error:
                return false
            }
        }
    }

    // MARK: - Initialization

    init() {
        setupAudioSession()
    }

    deinit {
        cleanup()
        stopTimer()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        // Note: AVAudioSession is iOS-specific
        // macOS handles audio sessions automatically
        // No explicit setup needed for macOS menu bar apps
    }

    // MARK: - Public Methods

    /// Plays audio from the specified YouTube URL
    func play(urlString: String) {
        guard URLValidator.isValidYouTubeURL(urlString) else {
            setError("Invalid YouTube URL")
            return
        }

        currentURL = urlString
        playbackState = .loading
        errorMessage = nil

        // Extract audio stream URL in background
        Task {
            await extractAndPlay(youtubeURL: urlString)
        }
    }

    /// Pauses the current playback
    func pause() {
        guard playbackState.canPause else { return }
        player?.pause()
        playbackState = .paused
        pauseTimer()
    }

    /// Stops the current playback and releases resources
    func stop() {
        guard playbackState.canStop else { return }
        cleanup()
        stopTimer()
        resetTimer()
        playbackState = .stopped
        currentURL = ""
    }

    /// Restarts playback from the beginning
    func restart() {
        let url = currentURL
        stop()

        // Small delay to ensure cleanup is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.play(urlString: url)
        }
    }

    /// Resumes playback if paused
    func resume() {
        guard case .paused = playbackState else { return }
        player?.play()
        playbackState = .playing
        startTimer()
    }

    /// Mutes the audio
    func mute() {
        player?.isMuted = true
        isMuted = true
    }

    /// Unmutes the audio
    func unmute() {
        player?.isMuted = false
        isMuted = false
    }

    /// Toggles mute state
    func toggleMute() {
        if isMuted {
            unmute()
        } else {
            mute()
        }
    }

    // MARK: - Private Methods

    /// Extracts audio stream URL using yt-dlp and starts playback
    private func extractAndPlay(youtubeURL: String) async {
        do {
            let streamURL = try await extractAudioStreamURL(from: youtubeURL)
            await MainActor.run {
                self.startPlayback(with: streamURL)
            }
        } catch {
            await MainActor.run {
                self.setError(error.localizedDescription)
            }
        }
    }

    /// Extracts audio stream URL using yt-dlp command-line tool
    private func extractAudioStreamURL(from youtubeURL: String) async throws -> URL {
        // Check if yt-dlp is installed
        let ytDlpPath = try await findYtDlp()

        // Run yt-dlp to extract audio stream URL
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ytDlpPath)
        process.arguments = [
            "--format", "bestaudio",
            "--get-url",
            youtubeURL
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw AudioPlaybackError.extractionFailed(errorMessage)
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let streamURL = URL(string: outputString) else {
            throw AudioPlaybackError.invalidStreamURL
        }

        return streamURL
    }

    /// Finds yt-dlp installation path
    private func findYtDlp() async throws -> String {
        // Try common installation paths
        let possiblePaths = [
            "/opt/homebrew/bin/yt-dlp",  // Homebrew on Apple Silicon
            "/usr/local/bin/yt-dlp",      // Homebrew on Intel
            "/usr/bin/yt-dlp",            // System installation
            "\(NSHomeDirectory())/.local/bin/yt-dlp"  // User local installation
        ]

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        // Try using 'which' command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["yt-dlp"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try? process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !path.isEmpty {
                return path
            }
        }

        throw AudioPlaybackError.ytDlpNotFound
    }

    /// Starts playback with the given stream URL
    private func startPlayback(with streamURL: URL) {
        cleanup()

        let playerItem = AVPlayerItem(url: streamURL)
        player = AVPlayer(playerItem: playerItem)
        player?.isMuted = isMuted

        // Observe player status
        statusObservation = playerItem.observe(\.status) { [weak self] item, _ in
            DispatchQueue.main.async {
                self?.handlePlayerStatusChange(item.status)
            }
        }

        // Start playback
        player?.play()
        playbackState = .playing
        startTimer()
    }

    /// Handles player status changes
    private func handlePlayerStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            if case .loading = playbackState {
                playbackState = .playing
            }
        case .failed:
            if let error = player?.currentItem?.error {
                setError(error.localizedDescription)
            } else {
                setError("Playback failed")
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }

    /// Sets error state
    private func setError(_ message: String) {
        errorMessage = message
        playbackState = .error(message)
        cleanup()
        stopTimer()
        resetTimer()
    }

    /// Cleans up player resources
    private func cleanup() {
        player?.pause()
        statusObservation?.invalidate()
        statusObservation = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    // MARK: - Time Tracking

    /// Starts the playback timer
    private func startTimer() {
        stopTimer() // Stop any existing timer
        playbackStartTime = Date()

        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }

    /// Pauses the playback timer
    private func pauseTimer() {
        if let startTime = playbackStartTime {
            accumulatedTime += Date().timeIntervalSince(startTime)
        }
        stopTimer()
    }

    /// Stops the playback timer
    private func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        playbackStartTime = nil
    }

    /// Resets the elapsed time
    private func resetTimer() {
        accumulatedTime = 0
        elapsedTime = 0
    }

    /// Updates the elapsed time
    private func updateElapsedTime() {
        guard let startTime = playbackStartTime else { return }
        elapsedTime = accumulatedTime + Date().timeIntervalSince(startTime)
    }

    /// Formats time interval to HH:MM:SS string
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
}

// MARK: - Audio Playback Errors

enum AudioPlaybackError: LocalizedError {
    case ytDlpNotFound
    case extractionFailed(String)
    case invalidStreamURL

    var errorDescription: String? {
        switch self {
        case .ytDlpNotFound:
            return "yt-dlp is not installed. Please install it using: brew install yt-dlp"
        case .extractionFailed(let message):
            return "Failed to extract audio stream: \(message)"
        case .invalidStreamURL:
            return "Invalid audio stream URL"
        }
    }
}
