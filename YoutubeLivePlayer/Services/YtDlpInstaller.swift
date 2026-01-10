//
//  YtDlpInstaller.swift
//  YoutubeLivePlayer
//
//  Created by Maxim Gorbatyuk on 10.01.2026.
//

import Foundation
import AppKit
import Combine

/// Manages yt-dlp installation and updates
class YtDlpInstaller: ObservableObject {
    @Published var isInstalling = false
    @Published var installationProgress: String = ""
    @Published var installationError: String?

    static let shared = YtDlpInstaller()

    private init() {}

    /// Path where we'll install yt-dlp locally
    private var installationPath: String {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appSupportPath = appSupportURL.path
        return "\(appSupportPath)/VibeCodingYTPlayer/yt-dlp"
    }

    /// Check if yt-dlp is installed locally
    func isYtDlpInstalled() -> Bool {
        FileManager.default.fileExists(atPath: installationPath)
    }

    /// Get the path to locally installed yt-dlp
    func getYtDlpPath() -> String? {
        FileManager.default.fileExists(atPath: installationPath) ? installationPath : nil
    }

    /// Show installation dialog and install if user approves
    func promptAndInstallIfNeeded(completion: @escaping (Bool) -> Void) {
        guard !isYtDlpInstalled() else {
            completion(true)
            return
        }

        // Show alert on main thread
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "yt-dlp Required"
            alert.informativeText = "VibeCodingYTPlayer needs yt-dlp to extract audio from YouTube.\n\nWould you like to download and install it now?\n\nyt-dlp will be installed locally\n(~5 MB download)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Download & Install")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Install Manually")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                // User chose to download and install
                self?.installYtDlp { success, error in
                    DispatchQueue.main.async {
                        if success {
                            let successAlert = NSAlert()
                            successAlert.messageText = "Installation Complete"
                            successAlert.informativeText = "yt-dlp has been successfully installed!\n\nYou can now play YouTube audio."
                            successAlert.alertStyle = .informational
                            successAlert.runModal()
                            completion(true)
                        } else {
                            let errorAlert = NSAlert()
                            errorAlert.messageText = "Installation Failed"
                            errorAlert.informativeText = error ?? "Could not install yt-dlp. Please install it manually using:\n\nbrew install yt-dlp"
                            errorAlert.alertStyle = .warning
                            errorAlert.runModal()
                            completion(false)
                        }
                    }
                }
            } else if response == .alertThirdButtonReturn {
                // User chose manual installation
                let manualAlert = NSAlert()
                manualAlert.messageText = "Manual Installation"
                manualAlert.informativeText = "To install yt-dlp manually, open Terminal and run:\n\nbrew install yt-dlp\n\nOr visit: https://github.com/yt-dlp/yt-dlp"
                manualAlert.alertStyle = .informational
                manualAlert.addButton(withTitle: "Open GitHub")
                manualAlert.addButton(withTitle: "Close")

                let manualResponse = manualAlert.runModal()
                if manualResponse == .alertFirstButtonReturn {
                    if let url = URL(string: "https://github.com/yt-dlp/yt-dlp#installation") {
                        NSWorkspace.shared.open(url)
                    }
                }
                completion(false)
            } else {
                // User cancelled
                completion(false)
            }
        }
    }

    /// Ensures yt-dlp is installed before allowing app to continue
    func ensureInstalled(completion: @escaping (Bool) -> Void) {
        if isYtDlpInstalled() {
            print("yt-dlp already installed at: \(installationPath)")
            completion(true)
            return
        }

        print("yt-dlp not found. Downloading from GitHub...")

        showProgressDialog { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }

            self.installYtDlp { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("yt-dlp installed successfully at: \(self.installationPath)")
                        self.hideProgressDialog()
                        completion(true)
                    } else {
                        print("Failed to install yt-dlp: \(error ?? "Unknown error")")
                        self.hideProgressDialog()
                        self.showErrorAlert(error)
                        completion(false)
                    }
                }
            }
        }
    }

    private var progressWindow: NSWindow?
    private var progressIndicator: NSProgressIndicator?

    private func showProgressDialog(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 120),
                styleMask: [.titled],
                backing: .buffered,
                defer: false
            )

            window.title = "Setting Up"
            window.center()
            window.isReleasedWhenClosed = false
            window.level = .floating

            let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 120))

            let label = NSTextField(labelWithString: "Downloading yt-dlp...")
            label.frame = NSRect(x: 20, y: 70, width: 360, height: 20)
            label.alignment = .center
            contentView.addSubview(label)

            let subLabel = NSTextField(labelWithString: "This may take a moment")
            subLabel.frame = NSRect(x: 20, y: 50, width: 360, height: 20)
            subLabel.alignment = .center
            subLabel.font = NSFont.systemFont(ofSize: 11)
            contentView.addSubview(subLabel)

            let progressIndicator = NSProgressIndicator()
            progressIndicator.frame = NSRect(x: 20, y: 20, width: 360, height: 20)
            progressIndicator.style = .bar
            progressIndicator.isIndeterminate = true
            progressIndicator.startAnimation(nil)
            contentView.addSubview(progressIndicator)

            self.progressIndicator = progressIndicator

            window.contentView = contentView
            self.progressWindow = window

            window.makeKeyAndOrderFront(nil)

            completion()
        }
    }

    private func hideProgressDialog() {
        DispatchQueue.main.async {
            if let window = self.progressWindow {
                window.orderOut(nil)
                self.progressWindow = nil
                self.progressIndicator = nil
            }
        }
    }

    private func showErrorAlert(_ error: String?) {
        let alert = NSAlert()
        alert.messageText = "Download Failed"
        alert.informativeText = "Could not download yt-dlp from GitHub.\n\nError: \(error ?? "Unknown error")\n\nPlease check your internet connection and try again."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Quit")
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }

    /// Download and install yt-dlp
    private func installYtDlp(completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.main.async {
            self.isInstalling = true
            self.installationProgress = "Downloading yt-dlp..."
        }

        // GitHub release URL for yt-dlp
        let downloadURL = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos"

        guard let url = URL(string: downloadURL) else {
            DispatchQueue.main.async {
                self.isInstalling = false
                self.installationError = "Invalid download URL"
            }
            completion(false, "Invalid download URL")
            return
        }

        // Create download task
        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            guard let self = self else { return }

            if let error = error {
                let nsError = error as NSError
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.installationError = error.localizedDescription
                }
                completion(false, "Download failed: \(error.localizedDescription)")
                return
            }

            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.installationError = "Download failed: No file received"
                }
                completion(false, "Download failed: No file received")
                return
            }

            DispatchQueue.main.async {
                self.installationProgress = "Installing yt-dlp..."
            }

            // Create .local/bin directory if it doesn't exist
            let binDirectory = (self.installationPath as NSString).deletingLastPathComponent
            do {
                try FileManager.default.createDirectory(atPath: binDirectory, withIntermediateDirectories: true)
            } catch {
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.installationError = "Could not create directory: \(error.localizedDescription)"
                }
                completion(false, "Could not create directory: \(error.localizedDescription)")
                return
            }

            // Move file to installation path
            do {
                // Remove existing file if present
                if FileManager.default.fileExists(atPath: self.installationPath) {
                    try FileManager.default.removeItem(atPath: self.installationPath)
                }

                try FileManager.default.moveItem(atPath: tempURL.path, toPath: self.installationPath)

                // Make it executable
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: self.installationPath)

                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.installationProgress = "Installation complete!"
                }

                completion(true, nil)
            } catch {
                DispatchQueue.main.async {
                    self.isInstalling = false
                    self.installationError = "Installation failed: \(error.localizedDescription)"
                }
                completion(false, "Installation failed: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    /// Check for updates (future enhancement)
    func checkForUpdates(completion: @escaping (Bool, String?) -> Void) {
        // TODO: Implement version checking
        completion(false, "Update checking not yet implemented")
    }
}
