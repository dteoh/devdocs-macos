import AppKit

public extension Notification.Name {
    static let MenuFindAction = Notification.Name(
        rawValue: "AppDelegateMenuFindActionNotification")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationWindows.shared
        URLEventHandler.shared.install()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Summoner.shared.install()

        if GeneralPreferences.shouldRestoreDocs {
            DocumentationWindows.shared.restore()
        }

        DispatchQueue.main.async {
            DocumentationWindows.shared.newWindowIfNoWindow()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DocumentationWindows.shared.persist()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            DocumentationWindows.shared.newWindow()
            return true
        }
    }

    @IBAction func newTab(_ sender: Any) {
        DocumentationWindows.shared.newWindow()
    }

    @IBAction func showAppPreferences(_ sender: Any) {
        PreferencesWindowController.shared.showWindow(self)
    }

    @IBAction func performFindAction(_ sender: Any) {
        NotificationCenter.default.post(name: .MenuFindAction, object: nil)
    }
}
