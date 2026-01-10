//
//  YtDlpInstaller.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 10.01.2026.
//

import Foundation
import AppKit
import Combine

/// Manages yt-dlp installation check
class YtDlpInstaller: ObservableObject {
    static let shared = YtDlpInstaller()

    private init() {}

    /// Check if yt-dlp is installed via brew
    func isYtDlpInstalled() -> Bool {
        let possiblePaths = [
            "/opt/homebrew/bin/yt-dlp",  // Homebrew on Apple Silicon
            "/usr/local/bin/yt-dlp",      // Homebrew on Intel
            "/usr/bin/yt-dlp"             // System installation
        ]

        for path in possiblePaths {
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            print("Checking \(path): \(exists ? "EXISTS" : "NOT FOUND")")
            if exists {
                let isExecutable = FileManager.default.isExecutableFile(atPath: path)
                print("Is executable: \(isExecutable)")
                return true
                /*if isExecutable {
                    return true
                }*/
            }
        }

        return false
    }

    /// Get the path to brew-installed yt-dlp
    func getYtDlpPath() -> String? {

        if let bundledPath = Bundle.main.path(forResource: "yt-dlp_macos", ofType: nil) {
            // Make sure it's executable
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: bundledPath
            )

            print("Bundled yt-dlp: \(bundledPath)")
            print("isExecutable: \(FileManager.default.isExecutableFile(atPath: bundledPath))")

            return bundledPath
        }
        
        let possiblePaths = [
            "/opt/homebrew/bin/yt-dlp",  // Homebrew on Apple Silicon
            "/usr/local/bin/yt-dlp",      // Homebrew on Intel
            "/usr/bin/yt-dlp"             // System installation
        ]

        for path in possiblePaths {
            if let resolved = resolveExecutablePath(path) {
                return resolved
            }
        }

        return nil
    }

    func resolveExecutablePath(_ path: String) -> String? {
        let fileManager = FileManager.default
        var resolvedPath = path

        // Keep resolving until we get to the actual file
        while true {
            guard fileManager.fileExists(atPath: resolvedPath) else {
                return nil
            }
            
            // Check if it's a symlink
            guard let attrs = try? fileManager.attributesOfItem(atPath: resolvedPath),
                  let fileType = attrs[.type] as? FileAttributeType else {
                return nil
            }
            
            if fileType == .typeSymbolicLink {
                // Resolve one level of symlink
                guard let destination = try? fileManager.destinationOfSymbolicLink(atPath: resolvedPath) else {
                    return nil
                }
                
                // Handle relative vs absolute paths
                if destination.hasPrefix("/") {
                    resolvedPath = destination
                } else {
                    // Relative path - resolve from symlink's directory
                    let directory = (resolvedPath as NSString).deletingLastPathComponent
                    resolvedPath = (directory as NSString).appendingPathComponent(destination)
                }
                
                // Standardize the path (resolve .. and .)
                resolvedPath = (resolvedPath as NSString).standardizingPath
            } else {
                // Not a symlink, we're done
                break
            }
        }
        
        // Verify it's executable
        guard fileManager.isExecutableFile(atPath: resolvedPath) else {
            print("File exists but is not executable: \(resolvedPath)")
            return nil
        }
        
        return resolvedPath
    }

    /// Ensures yt-dlp is installed via brew before allowing app to continue
    func ensureInstalled(completion: @escaping (Bool) -> Void) {
        if isYtDlpInstalled() {
            let path = getYtDlpPath() ?? "unknown"
            print("yt-dlp found at: \(path)")
            completion(true)
            return
        }

        print("yt-dlp not found via brew. Showing installation instructions...")

        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "yt-dlp Required"
            alert.informativeText = "VibeCodingYTPlayer requires yt-dlp to extract audio from YouTube.\n\nPlease install it using Homebrew by running the following command in Terminal:\n\nbrew install yt-dlp"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                NSApplication.shared.terminate(nil)
            }

            completion(false)
        }
    }
}
