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
        observeDocumentTitle()
        observeEffectiveAppearance()
    }

    private func observeDocumentTitle() {
        if let dvc = documentationViewController {
            observations.insert(
                dvc.observe(\DocumentationViewController.documentTitle) { (dvc, _) in
                    self.window?.title = dvc.documentTitle ?? "DevDocs"
                }
            )
        }
    }

    private func observeEffectiveAppearance() {
        if let window = self.window {
            observations.insert(
                window.observe(\NSWindow.effectiveAppearance) { (win, _) in
                    guard let dvc = self.documentationViewController else {
                        return
                    }
                    switch window.effectiveAppearance.name {
                    case .aqua:
                        dvc.useDarkMode(false)
                    case .darkAqua:
                        dvc.useDarkMode(true)
                    default:
                        break;
                    }
                }
            )
        }
    }

}
