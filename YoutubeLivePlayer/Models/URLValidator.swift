//
//  URLValidator.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 09.01.2026.
//

import Foundation

struct URLValidator {
    /// Validates if a string is a valid YouTube URL
    /// Supports formats:
    /// - https://www.youtube.com/watch?v=VIDEO_ID
    /// - https://youtu.be/VIDEO_ID
    /// - https://www.youtube.com/live/VIDEO_ID
    /// - https://m.youtube.com/watch?v=VIDEO_ID
    static func isValidYouTubeURL(_ urlString: String) -> Bool {
        guard !urlString.isEmpty else { return false }

        guard let url = URL(string: urlString) else { return false }

        guard let host = url.host?.lowercased() else { return false }

        // Check for valid YouTube domains
        let validHosts = [
            "www.youtube.com",
            "youtube.com",
            "m.youtube.com",
            "youtu.be"
        ]

        guard validHosts.contains(host) else { return false }

        // Check for valid paths and video ID
        if host == "youtu.be" {
            // Format: https://youtu.be/VIDEO_ID
            return !url.pathComponents.filter { $0 != "/" }.isEmpty
        } else {
            // Format: youtube.com/watch?v=VIDEO_ID or youtube.com/live/VIDEO_ID
            let path = url.path.lowercased()
            let hasVideoParam = url.query?.contains("v=") ?? false
            let isLivePath = path.contains("/live/")
            let isWatchPath = path.contains("/watch")

            return (isWatchPath && hasVideoParam) || isLivePath
        }
    }

    /// Extracts video ID from YouTube URL if valid
    static func extractVideoID(from urlString: String) -> String? {
        guard isValidYouTubeURL(urlString),
              let url = URL(string: urlString) else {
            return nil
        }

        let host = url.host?.lowercased() ?? ""

        if host == "youtu.be" {
            // Format: https://youtu.be/VIDEO_ID
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            return pathComponents.first
        } else {
            // Check for v= parameter
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
               let videoID = queryItems.first(where: { $0.name == "v" })?.value {
                return videoID
            }

            // Check for /live/VIDEO_ID format
            if url.path.contains("/live/") {
                let pathComponents = url.pathComponents.filter { $0 != "/" && $0 != "live" }
                return pathComponents.first
            }
        }

        return nil
    }
}
