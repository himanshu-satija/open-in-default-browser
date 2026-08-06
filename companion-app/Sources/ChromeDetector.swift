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

        // Discover all Chrome profiles (Default, Profile 1, Profile 2, etc.)
        let profiles: [String]
        if let subdirs = try? FileManager.default.contentsOfDirectory(atPath: chromeDir.path) {
            let matched = subdirs.filter { $0 == "Default" || $0.hasPrefix("Profile ") }
            profiles = matched.isEmpty ? ["Default", "Profile 1", "Profile 2", "Profile 3"] : matched
        } else {
            profiles = ["Default", "Profile 1", "Profile 2", "Profile 3"]
        }

        // First try standard installed extensions folder
        for profile in profiles {
            if let extensionID = searchInProfile(chromeDir: chromeDir, profile: profile) {
                return extensionID
            }
        }

        // Fallback: search Preferences & Secure Preferences JSON for unpacked developer extensions
        for profile in profiles {
            if let extensionID = searchInProfilePreferences(chromeDir: chromeDir, profile: profile) {
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

    private func searchInProfilePreferences(chromeDir: URL, profile: String) -> String? {
        let prefFiles = ["Secure Preferences", "Preferences"]

        for prefFile in prefFiles {
            let prefPath = chromeDir.appendingPathComponent("\(profile)/\(prefFile)")
            guard FileManager.default.fileExists(atPath: prefPath.path),
                  let data = try? Data(contentsOf: prefPath),
                  let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                  let extensions = json["extensions"] as? [String: Any],
                  let settings = extensions["settings"] as? [String: Any] else {
                continue
            }

            for (extID, extInfo) in settings {
                guard let extDict = extInfo as? [String: Any] else { continue }

                var manifest: [String: Any]? = extDict["manifest"] as? [String: Any]
                let pathStr = extDict["path"] as? String ?? ""

                // For unpacked extensions, load manifest.json from the path on disk if available
                if manifest == nil || (manifest?["name"] as? String)?.isEmpty == true {
                    if !pathStr.isEmpty {
                        let manifestURL = URL(fileURLWithPath: pathStr).appendingPathComponent("manifest.json")
                        manifest = loadManifest(at: manifestURL)
                    }
                }

                if let manifest = manifest {
                    if let name = manifest["name"] as? String {
                        let lowerName = name.lowercased()
                        if name.contains(extensionName) || lowerName.contains("default browser") || (lowerName.contains("open") && lowerName.contains("browser")) {
                            return extID
                        }
                    }
                }

                // Additional check on path string for unpacked extensions
                let lowerPath = pathStr.lowercased()
                if lowerPath.contains("open-in-default-browser") || (lowerPath.contains("open") && lowerPath.contains("default") && lowerPath.contains("browser")) {
                    return extID
                }
            }
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
