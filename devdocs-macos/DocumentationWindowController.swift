import AppKit
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
        dvc.delegate = self
        dvc.documentURL = documentation.url
    }

    override func windowWillLoad() {
        observations = Set()
    }

    override func windowDidLoad() {
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeMenuFindAction),
                                               name: .MenuFindAction,
                                               object: nil)
    }

    // MARK:- NotificationCenter observers

    @objc private func observeViewerState() {
        guard let dvc = documentationViewController else { return }

        if dvc.viewerState != .ready {
            return
        }

        dvc.overridePreferencesExport()
        dvc.useNativeScrollbars(true)
    }

    @objc private func observeDocumentTitle() {
        guard let dvc = documentationViewController else { return }
        self.window?.title = dvc.documentTitle ?? "DevDocs"
    }

    @objc private func observeDocumentURL() {
        guard let dvc = documentationViewController else { return }
        self.documentation.url = dvc.documentURL
    }

    @objc private func observeMenuFindAction() {
        guard let window = self.window else { return }
        if !window.isKeyWindow {
            return
        }

        guard let dvc = documentationViewController else { return }
        dvc.showSearchControl()
    }
}

// MARK:- DocumentationViewDelegate
extension DocumentationWindowController: DocumentationViewDelegate {
    func selectFileToOpen(_ parameters: OpenPanelParameters, completionHandler: @escaping ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = parameters.allowsDirectories
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.allowedFileTypes = ["json"]
        panel.allowsOtherFileTypes = false
        panel.resolvesAliases = true

        panel.beginSheetModal(for: self.window!) { modalResponse in
            if modalResponse == NSApplication.ModalResponse.OK, let url = panel.url {
                completionHandler([url])
            } else {
                completionHandler(nil)
            }
        }
    }

    func savePreferencesToFile(_ preferences: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "devdocs-preferences.json"
        panel.allowedFileTypes = ["json"]
        panel.allowsOtherFileTypes = false
        panel.isExtensionHidden = false

        panel.beginSheetModal(for: self.window!) { modalResponse in
            if modalResponse == NSApplication.ModalResponse.OK, let url = panel.url {
                do {
                    try preferences.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    NSApplication.shared.presentError(error)
                }
            }
        }
    }
}
