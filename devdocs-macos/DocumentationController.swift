import Cocoa

class DocumentationController: NSDocumentController {
    override func newDocument(_ sender: Any?) {
        let dc = DocumentationWindowController.init(window: nil);
        dc.showWindow(self);
    }
}
