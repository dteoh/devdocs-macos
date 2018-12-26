import Cocoa

class DocumentationWindows: NSObject, NSWindowDelegate {
    private var windowControllers: Set<DocumentationWindowController>

    static let shared = DocumentationWindows()

    private override init() {
        windowControllers = Set()
    }

    func newWindow() {
        newWindowFor(documentation: Documentation.init())
    }

    func newWindowFor(url: URL) {
        newWindowFor(documentation: Documentation.init(withURL: url))
    }

    func newWindowIfNoWindow() {
        if windowControllers.count == 0 {
            newWindow()
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as! NSWindow? else { return }
        guard let dwc = window.windowController as! DocumentationWindowController? else {
            return
        }
        windowControllers.remove(dwc)
    }

    private func newWindowFor(documentation: Documentation) {
        let dwc = DocumentationWindowController.init(window: nil)
        dwc.documentation = documentation
        dwc.window?.delegate = self

        windowControllers.insert(dwc)

        dwc.showWindow(self)
    }

    // MARK:- State restoration

    func persist() {
        var urls = [URL]()
        windowControllers.forEach { dwc in
            urls.append(dwc.documentation.url)
        }
        Storage.setLocations(urls)
    }

    func restore() {
        if let urls = Storage.getLocations() {
            urls.filter { url -> Bool in
                if let host = url.host {
                    return host == "devdocs.io"
                } else {
                    return false
                }
            }.forEach { url in
                newWindowFor(url: url)
            }
        } else {
            newWindow()
        }
    }

}
