import Cocoa

class DocumentationWindows: NSObject {
    private var windowControllers: Set<DocumentationWindowController>

    static let shared = DocumentationWindows()

    private override init() {
        windowControllers = Set()
    }

    func newWindow() {
        let dwc = DocumentationWindowController.init(window: nil)
        windowControllers.insert(dwc)

        let documentation = Documentation.init()

        dwc.showWindow(self)
    }
}
