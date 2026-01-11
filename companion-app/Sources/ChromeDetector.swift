import Foundation

class ChromeDetector {
    private let extensionName = "Open in Default Browser"
    private let chromeExtensionsPath = "Library/Application Support/Google/Chrome"

    func detectExtensionID() -> String? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let chromeDir = homeDir.appendingPathComponent(chromeExtensionsPath)

        // Check if Chrome directory exists
        guard FileManager.default.fileExists(atPath: chromeDir.path) else {
            return nil
        }

        // Search through Chrome profiles
        let profiles = ["Default", "Profile 1", "Profile 2", "Profile 3"]

        for profile in profiles {
            if let extensionID = searchInProfile(chromeDir: chromeDir, profile: profile) {
                return extensionID
            }
        }

        return nil
    }

    private func searchInProfile(chromeDir: URL, profile: String) -> String? {
        let extensionsDir = chromeDir.appendingPathComponent("\(profile)/Extensions")

        guard FileManager.default.fileExists(atPath: extensionsDir.path) else {
            return nil
        }

        do {
            let extensionDirs = try FileManager.default.contentsOfDirectory(atPath: extensionsDir.path)

            for extensionID in extensionDirs {
                let extensionPath = extensionsDir.appendingPathComponent(extensionID)

                // Get version directories
                if let versions = try? FileManager.default.contentsOfDirectory(atPath: extensionPath.path) {
                    for version in versions {
                        let manifestPath = extensionPath.appendingPathComponent("\(version)/manifest.json")

                        if let manifest = loadManifest(at: manifestPath) {
                            // Check if this is our extension
                            if let name = manifest["name"] as? String,
                               name.contains(extensionName) || name.contains("default browser") {
                                return extensionID
                            }

                            // Also check if it has nativeMessaging permission (fallback)
                            if let permissions = manifest["permissions"] as? [String],
                               permissions.contains("nativeMessaging") {
                                // Additional check: see if name matches closely
                                if let name = manifest["name"] as? String,
                                   name.lowercased().contains("open") && name.lowercased().contains("browser") {
                                    return extensionID
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error searching Chrome extensions: \(error)")
        }

        return nil
    }

    private func loadManifest(at path: URL) -> [String: Any]? {
        guard FileManager.default.fileExists(atPath: path.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: path)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }

    func getChromeExtensionURL(extensionID: String) -> String {
        return "chrome-extension://\(extensionID)/"
    }
}
