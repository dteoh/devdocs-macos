import Cocoa
import WebKit

class DocumentationWindowController: NSWindowController {

    @IBOutlet weak var documentationViewController: DocumentationViewController?

    private var observations: Set<NSKeyValueObservation>!

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("DocumentationWindow")
    }

    override func windowDidLoad() {
        observations = Set()

        if let dvc = documentationViewController {
            observations.insert(
                dvc.observe(\DocumentationViewController.documentTitle) { (dvc, _) in
                    self.window?.title = dvc.documentTitle ?? "DevDocs"
                }
            )
        }
    }
}
