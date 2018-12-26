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
        observeViewerState()
        observeDocumentTitle()
        observeEffectiveAppearance()
    }

    private func observeViewerState() {
        guard let dvc = documentationViewController else { return }
        observations.insert(
            dvc.observe(\DocumentationViewController.viewerState) { (dvc, _) in
                if dvc.viewerState != .ready {
                    return
                }

                dvc.useNativeScrollbars(true)

                guard let window = self.window else { return }
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

    private func observeDocumentTitle() {
        guard let dvc = documentationViewController else { return }
        observations.insert(
            dvc.observe(\DocumentationViewController.documentTitle) { (dvc, _) in
                self.window?.title = dvc.documentTitle ?? "DevDocs"
            }
        )
    }

    private func observeEffectiveAppearance() {
        guard let window = self.window else { return }
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
