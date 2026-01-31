import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var installManager: InstallManager?
    var chromeDetector: ChromeDetector?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Load custom tray icon
            if let image = loadTrayIcon() {
                image.isTemplate = true  // Enable automatic dark/light mode tinting
                button.image = image
            } else {
                // Fallback to emoji if custom icon fails to load
                button.title = "🌐"
            }
        }

        // Initialize managers
        chromeDetector = ChromeDetector()
        installManager = InstallManager(chromeDetector: chromeDetector!)

        // Create menu
        createMenu()

        // Show welcome message on first launch
        showWelcomeIfNeeded()
    }

    func createMenu() {
        let menu = NSMenu()

        // Install status item
        let statusMenuItem = NSMenuItem(title: getInstallStatus(), action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Install button
        let installItem = NSMenuItem(title: "Install Native Host", action: #selector(install), keyEquivalent: "i")
        installItem.target = self
        menu.addItem(installItem)

        // Uninstall button
        let uninstallItem = NSMenuItem(title: "Uninstall Native Host", action: #selector(uninstall), keyEquivalent: "u")
        uninstallItem.target = self
        menu.addItem(uninstallItem)

        menu.addItem(NSMenuItem.separator())

        // About
        let aboutItem = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    func getInstallStatus() -> String {
        if let isInstalled = installManager?.isInstalled(), isInstalled {
            return "✓ Installed"
        } else {
            return "✗ Not Installed"
        }
    }

    @objc func install() {
        guard let installManager = installManager else { return }

        let result = installManager.install()

        if result.success {
            showAlert(title: "Success", message: "Companion app installed successfully!\n\nYou can now use 'Open in Default Browser' in Chrome.")
        } else {
            showAlert(title: "Installation Failed", message: result.message)
        }

        // Refresh menu to update status
        createMenu()
    }

    @objc func uninstall() {
        guard let installManager = installManager else { return }

        let result = installManager.uninstall()

        if result.success {
            showAlert(title: "Success", message: "Companion app uninstalled successfully.")
        } else {
            showAlert(title: "Uninstallation Failed", message: result.message)
        }

        // Refresh menu to update status
        createMenu()
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Open in Default Browser"
        alert.informativeText = "Version 1.0.0\n\nA companion app for the Chrome extension that allows you to open links in your default browser.\n\n© 2025 Himanshu Satija\nMIT License"
        alert.alertStyle = .informational

        // Set custom icon
        if let icon = loadAlertIcon() {
            alert.icon = icon
        }

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "GitHub")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://github.com/himanshu-satija/open-in-default-browser") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational

        // Set custom icon
        if let icon = loadAlertIcon() {
            alert.icon = icon
        }

        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func showWelcomeIfNeeded() {
        // Check if we've already shown the welcome message
        let hasShownWelcome = UserDefaults.standard.bool(forKey: "hasShownWelcome")

        if !hasShownWelcome {
            // Small delay to ensure menu bar icon is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = NSAlert()
                alert.messageText = "Welcome!"
                alert.informativeText = "The companion app is now in your menu bar (look for the logo in the top right).\n\nClick 'Show Menu' to install the native host, which enables the Chrome extension to open links in your default browser.\n\nYou can open this menu anytime to install or uninstall the native host."
                alert.alertStyle = .informational

                // Set custom icon
                if let icon = self.loadAlertIcon() {
                    alert.icon = icon
                }

                alert.addButton(withTitle: "Show Menu")
                alert.runModal()

                // Mark as shown
                UserDefaults.standard.set(true, forKey: "hasShownWelcome")

                // Open the menu to show install option
                self.statusItem?.button?.performClick(nil)
            }
        }
    }

    func loadTrayIcon() -> NSImage? {
        // Get the directory where the app binary is located
        let executablePath = Bundle.main.executablePath ?? ""
        let executableDir = (executablePath as NSString).deletingLastPathComponent

        // Try to load the @2x version first for retina displays
        let icon2xPath = (executableDir as NSString).appendingPathComponent("tray-icon-44.png")
        let icon1xPath = (executableDir as NSString).appendingPathComponent("tray-icon-22.png")

        if let image = NSImage(contentsOfFile: icon2xPath) {
            image.size = NSSize(width: 22, height: 22)
            return image
        } else if let image = NSImage(contentsOfFile: icon1xPath) {
            image.size = NSSize(width: 22, height: 22)
            return image
        }

        return nil
    }

    func loadAlertIcon() -> NSImage? {
        // Get the directory where the app binary is located
        let executablePath = Bundle.main.executablePath ?? ""
        let executableDir = (executablePath as NSString).deletingLastPathComponent

        // Load the 64x64 logo for alerts
        let logoPath = (executableDir as NSString).appendingPathComponent("logo-64.png")

        if let image = NSImage(contentsOfFile: logoPath) {
            image.size = NSSize(width: 64, height: 64)
            return image
        }

        return nil
    }
}
