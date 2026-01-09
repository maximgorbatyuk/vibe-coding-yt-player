//
//  SettingsView.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .padding(.top)

            Spacer()

            // Placeholder for settings controls
            // Will be implemented in Phase 3
            VStack(spacing: 10) {
                Text("App Version: 2026.1.1")
                    .foregroundColor(.secondary)

                Text("Settings controls will appear here")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(minWidth: 300, minHeight: 400)
        .padding()
    }
}

#Preview {
    SettingsView()
}
