import Foundation

struct InstallResult {
    let success: Bool
    let message: String
}

class InstallManager {
    private let chromeDetector: ChromeDetector
    private let hostName = "com.openindefaultbrowser.host"
    private let nativeMessagingDir: URL
    private let manifestPath: URL

    init(chromeDetector: ChromeDetector) {
        self.chromeDetector = chromeDetector

        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        self.nativeMessagingDir = homeDir.appendingPathComponent("Library/Application Support/Google/Chrome/NativeMessagingHosts")
        self.manifestPath = nativeMessagingDir.appendingPathComponent("\(hostName).json")
    }

    func isInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: manifestPath.path)
    }

    func install() -> InstallResult {
        // Detect extension ID
        guard let extensionID = chromeDetector.detectExtensionID() else {
            return InstallResult(
                success: false,
                message: "Could not find the Chrome extension.\n\nPlease make sure you have installed the 'Open in Default Browser' extension from the Chrome Web Store."
            )
        }

        // Get app bundle path
        guard let appPath = Bundle.main.resourcePath else {
            return InstallResult(
                success: false,
                message: "Could not determine app location."
            )
        }

        // Path to the bundled host binary
        let hostBinarySource = URL(fileURLWithPath: appPath).appendingPathComponent("host-binary")

        guard FileManager.default.fileExists(atPath: hostBinarySource.path) else {
            return InstallResult(
                success: false,
                message: "Host binary not found in app bundle.\n\nPath: \(hostBinarySource.path)"
            )
        }

        // Create native messaging directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: nativeMessagingDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return InstallResult(
                success: false,
                message: "Failed to create native messaging directory:\n\(error.localizedDescription)"
            )
        }

        // Copy host binary to a permanent location
        let hostBinaryDest = nativeMessagingDir.appendingPathComponent("open-in-default-browser-host")

        // Remove existing binary if present
        if FileManager.default.fileExists(atPath: hostBinaryDest.path) {
            do {
                try FileManager.default.removeItem(at: hostBinaryDest)
            } catch {
                return InstallResult(
                    success: false,
                    message: "Failed to remove existing host binary:\n\(error.localizedDescription)"
                )
            }
        }

        // Copy binary
        do {
            try FileManager.default.copyItem(at: hostBinarySource, to: hostBinaryDest)
            // Make it executable
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: hostBinaryDest.path)
        } catch {
            return InstallResult(
                success: false,
                message: "Failed to copy host binary:\n\(error.localizedDescription)"
            )
        }

        // Create manifest
        let manifest: [String: Any] = [
            "name": hostName,
            "description": "Native messaging host to open URLs in default browser",
            "path": hostBinaryDest.path,
            "type": "stdio",
            "allowed_origins": [chromeDetector.getChromeExtensionURL(extensionID: extensionID)]
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: manifestPath)
        } catch {
            return InstallResult(
                success: false,
                message: "Failed to create manifest file:\n\(error.localizedDescription)"
            )
        }

        return InstallResult(
            success: true,
            message: "Installation successful!"
        )
    }

    func uninstall() -> InstallResult {
        var errors: [String] = []

        // Remove manifest
        if FileManager.default.fileExists(atPath: manifestPath.path) {
            do {
                try FileManager.default.removeItem(at: manifestPath)
            } catch {
                errors.append("Failed to remove manifest: \(error.localizedDescription)")
            }
        }

        // Remove host binary
        let hostBinaryPath = nativeMessagingDir.appendingPathComponent("open-in-default-browser-host")
        if FileManager.default.fileExists(atPath: hostBinaryPath.path) {
            do {
                try FileManager.default.removeItem(at: hostBinaryPath)
            } catch {
                errors.append("Failed to remove host binary: \(error.localizedDescription)")
            }
        }

        if errors.isEmpty {
            return InstallResult(
                success: true,
                message: "Uninstallation successful!"
            )
        } else {
            return InstallResult(
                success: false,
                message: "Uninstallation completed with errors:\n\(errors.joined(separator: "\n"))"
            )
        }
    }
}
