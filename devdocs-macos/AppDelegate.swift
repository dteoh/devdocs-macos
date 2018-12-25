import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationController.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DocumentationController.shared.newDocument(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
