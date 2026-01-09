//
//  MainView.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Main Screen")
                .font(.title)
                .padding(.top)

            Spacer()

            // Placeholder for main screen controls
            // Will be implemented in Phase 6
            Text("Audio controls will appear here")
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(minWidth: 300, minHeight: 400)
        .padding()
    }
}

#Preview {
    MainView()
}
