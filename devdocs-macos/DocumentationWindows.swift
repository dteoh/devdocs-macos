import Cocoa

class DocumentationWindows: NSObject, NSWindowDelegate {
    private var windowControllers: Set<DocumentationWindowController>

    static let shared = DocumentationWindows()

    private override init() {
        windowControllers = Set()
    }

    func newWindow() {
        let dwc = DocumentationWindowController.init(window: nil)
        dwc.window?.delegate = self

        windowControllers.insert(dwc)

        dwc.showWindow(self)
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as! NSWindow? else { return }
        guard let dwc = window.windowController as! DocumentationWindowController? else {
            return
        }
        windowControllers.remove(dwc)
    }

}
