import Cocoa
import WebKit

class DocumentationWindowController: NSWindowController {

    @IBOutlet weak var documentationViewController: DocumentationViewController?

    var documentation: Documentation!
    private var observations: Set<NSKeyValueObservation>!

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("DocumentationWindow")
    }

    override func awakeFromNib() {
        guard let dvc = documentationViewController else { return }
        dvc.documentURL = documentation.url
    }

    override func windowWillLoad() {
        observations = Set()
    }

    override func windowDidLoad() {
        observeEffectiveAppearance()

        guard let dvc = documentationViewController else { return }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeViewerState),
                                               name: .DocumentViewerStateDidChange,
                                               object: dvc)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeDocumentTitle),
                                               name: .DocumentTitleDidChange,
                                               object: dvc)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeDocumentURL),
                                               name: .DocumentURLDidChange,
                                               object: dvc)
    }

    func activateFind() {
        guard let dvc = documentationViewController else { return }
        dvc.showSearchControl()
    }

    @objc private func observeViewerState() {
        guard let dvc = documentationViewController else { return }

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

    @objc private func observeDocumentTitle() {
        guard let dvc = documentationViewController else { return }
        self.window?.title = dvc.documentTitle ?? "DevDocs"
    }

    @objc private func observeDocumentURL() {
        guard let dvc = documentationViewController else { return }
        self.documentation.url = dvc.documentURL
    }

    private func observeEffectiveAppearance() {
        guard let window = self.window else { return }
        observations.insert(
            window.observe(\NSWindow.effectiveAppearance) { [weak self] (win, _) in
                guard let dvc = self?.documentationViewController else {
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
