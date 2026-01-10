//
//  SettingsView.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI

struct SettingsView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var body: some View {
        VStack(spacing: 30) {
            Text("Settings")
                .font(.title)
                .padding(.top)

            Spacer()

            // App Information Section
            VStack(spacing: 12) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("VibeCodingYTPlayer")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Audio player for YouTube live streams")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 20)

            Spacer()

            // Quit Button
            Button(action: quitApp) {
                Label("Quit App", systemImage: "power")
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
