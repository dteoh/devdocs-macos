import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var hotKey: HotKey!

    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationController.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupHotKey()
        DocumentationController.shared.newDocument(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func setupHotKey() {
        hotKey = HotKey(key: .space, modifiers: [.option])
        hotKey.keyDownHandler = hotKeyPressed
    }

    private func hotKeyPressed() {
        NSApp.activate(ignoringOtherApps: true)
    }
}
