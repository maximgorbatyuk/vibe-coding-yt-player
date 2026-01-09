//
//  SettingsView.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("youtubeURL") private var youtubeURL: String = ""

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var isURLValid: Bool {
        youtubeURL.isEmpty || URLValidator.isValidYouTubeURL(youtubeURL)
    }

    private var urlValidationMessage: String {
        if youtubeURL.isEmpty {
            return "The URL will be saved automatically"
        } else if URLValidator.isValidYouTubeURL(youtubeURL) {
            if let videoID = URLValidator.extractVideoID(from: youtubeURL) {
                return "Valid YouTube URL (Video ID: \(videoID))"
            }
            return "Valid YouTube URL"
        } else {
            return "Invalid YouTube URL format"
        }
    }

    private var validationColor: Color {
        if youtubeURL.isEmpty {
            return .secondary
        } else if URLValidator.isValidYouTubeURL(youtubeURL) {
            return .green
        } else {
            return .red
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .padding(.top)

            // YouTube URL Section
            VStack(alignment: .leading, spacing: 8) {
                Text("YouTube Live Stream URL")
                    .font(.headline)

                HStack {
                    TextField("Enter YouTube URL", text: $youtubeURL)
                        .textFieldStyle(.roundedBorder)

                    // Validation indicator
                    if !youtubeURL.isEmpty {
                        Image(systemName: isURLValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isURLValid ? .green : .red)
                            .imageScale(.large)
                    }
                }

                Text(urlValidationMessage)
                    .font(.caption)
                    .foregroundColor(validationColor)
            }
            .padding(.horizontal)

            Spacer()

            // App Information Section
            VStack(spacing: 8) {
                Text("Youtube Live Player")
                    .font(.headline)

                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 10)

            // Quit Button
            Button(action: quitApp) {
                Text("Quit App")
                    .frame(maxWidth: 150)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.bottom)
        }
        .frame(minWidth: 300, minHeight: 400)
        .padding()
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    SettingsView()
}
