import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var installManager: InstallManager?
    var chromeDetector: ChromeDetector?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Use SF Symbol for the menu bar icon
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "safari", accessibilityDescription: "Open in Default Browser")
            } else {
                button.title = "🌐"
            }
        }

        // Initialize managers
        chromeDetector = ChromeDetector()
        installManager = InstallManager(chromeDetector: chromeDetector!)

        // Create menu
        createMenu()
    }

    func createMenu() {
        let menu = NSMenu()

        // Install status item
        let statusMenuItem = NSMenuItem(title: getInstallStatus(), action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Install button
        let installItem = NSMenuItem(title: "Install", action: #selector(install), keyEquivalent: "i")
        installItem.target = self
        menu.addItem(installItem)

        // Uninstall button
        let uninstallItem = NSMenuItem(title: "Uninstall", action: #selector(uninstall), keyEquivalent: "u")
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
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
