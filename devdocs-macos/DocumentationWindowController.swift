import Cocoa
import WebKit

class DocumentationWindowController: NSWindowController {
    @IBOutlet weak var documentationViewController: DocumentationViewController?

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("DocumentationWindow")
    }
}
