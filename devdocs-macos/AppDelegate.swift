import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationWindows.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Summoner.shared.install()
        URLEventHandler.shared.install()
        DocumentationWindows.shared.restore()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DocumentationWindows.shared.persist()
    }

    @IBAction func newTab(_ sender: Any) {
        DocumentationWindows.shared.newWindow()
    }

    @IBAction func showAppPreferences(_ sender: Any) {
        PreferencesWindowController.shared.showWindow(self)
    }

    @IBAction func performFindAction(_ sender: Any) {
        guard let window = NSApp.mainWindow else { return }
        let dwc = window.windowController.map { wc in
            wc as! DocumentationWindowController
        }
        dwc?.activateFind()
    }
}
