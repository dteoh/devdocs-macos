import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationWindows.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Summoner.shared.install()
        DocumentationWindows.shared.restore()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DocumentationWindows.shared.persist()
    }

    @IBAction func newTab(sender: Any) {
        DocumentationWindows.shared.newWindow()
    }

    @IBAction func showAppPreferences(sender: Any) {
        PreferencesWindowController.shared.showWindow(self)
    }
}
