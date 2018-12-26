import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var hotKey: HotKey!

    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationWindows.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupHotKey()
        DocumentationWindows.shared.restore()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DocumentationWindows.shared.persist()
    }

    @IBAction func newTab(sender: Any) {
        DocumentationWindows.shared.newWindow()
    }

    private func setupHotKey() {
        hotKey = HotKey(key: .space, modifiers: [.option])
        hotKey.keyDownHandler = hotKeyPressed
    }

    private func hotKeyPressed() {
        NSApp.activate(ignoringOtherApps: true)
    }
}
