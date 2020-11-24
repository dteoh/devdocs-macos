import AppKit
import WebKit

class DocumentationWindowController: NSWindowController {

    @IBOutlet weak var documentationViewController: DocumentationViewController?

    var documentation: Documentation!
    private var observations: Set<NSKeyValueObservation>!
    private var contentSearchField: NSSearchField?

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

        setupToolbar()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeViewerState),
                                               name: .DocumentViewerStateDidChange,
                                               object: dvc)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeDocumentTitle),
                                               name: .DocumentTitleDidChange,
                                               object: dvc)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeDocumentCategory),
                                               name: .DocumentCategoryDidChange,
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

    private func setupToolbar() {
        let toolbar = NSToolbar(identifier: "DocumentationWindowToolbar")
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self
        window?.toolbar = toolbar
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

    @objc private func observeDocumentCategory() {
        guard let dvc = documentationViewController else { return }
        self.window?.subtitle = dvc.documentCategory ?? ""
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

        window.makeFirstResponder(contentSearchField)
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

// MARK:- NSToolbarItem.Identifier
extension NSToolbarItem.Identifier {
    static let historyNavigation: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "HistoryNavigation")
    static let contentSearch: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "ContentSearch")

    // Sub items
    static let navigateBack: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "NavigateBack")
    static let navigateForward: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "NavigateForward")
}

// MARK:- NSToolbarDelegate
extension DocumentationWindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .historyNavigation,
            .space,
            .flexibleSpace,
            .contentSearch
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.historyNavigation, .flexibleSpace, .contentSearch]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .historyNavigation:
            let item = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
            item.label = NSLocalizedString("Back / Forward", comment: "History navigation")
            item.isNavigational = true

            let backItem = NSToolbarItem(itemIdentifier: .navigateBack)
            backItem.label = NSLocalizedString("Back", comment: "Navigate back")
            backItem.image = NSImage(systemSymbolName: "chevron.backward", accessibilityDescription: backItem.label)

            let forwardItem = NSToolbarItem(itemIdentifier: .navigateForward)
            forwardItem.label = NSLocalizedString("Forward", comment: "Navigate forward")
            forwardItem.image = NSImage(systemSymbolName: "chevron.forward", accessibilityDescription: forwardItem.label)

            item.subitems = [backItem, forwardItem]
            return item
        case .contentSearch:
            let item = NSSearchToolbarItem(itemIdentifier: itemIdentifier)
            item.searchField.recentsAutosaveName = NSSearchField.RecentsAutosaveName("content-search-term")
            return item
        default:
            return nil
        }
    }

    func toolbarWillAddItem(_ notification: Notification) {
        guard let item = notification.userInfo?["item"] as? NSToolbarItem else {
            return
        }

        switch item.itemIdentifier {
        case .contentSearch:
            let searchItem = item as! NSSearchToolbarItem
            searchItem.searchField.delegate = documentationViewController
            searchItem.searchField.target = documentationViewController
            searchItem.searchField.action = #selector(documentationViewController?.searchPageContents(_:))
            contentSearchField = searchItem.searchField
        default:
            return
        }
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
        guard let item = notification.userInfo?["item"] as? NSToolbarItem else {
            return
        }

        switch item.itemIdentifier {
        case .contentSearch:
            contentSearchField = nil

            let searchItem = item as! NSSearchToolbarItem
            searchItem.searchField.delegate = nil
            searchItem.searchField.target = nil
            searchItem.searchField.action = nil
        default:
            return
        }
    }
}
