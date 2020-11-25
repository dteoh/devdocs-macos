import AppKit
import WebKit

class DocumentationWindowController: NSWindowController {

    @IBOutlet weak var documentationViewController: DocumentationViewController?

    var documentation: Documentation!
    private var observations: Set<NSKeyValueObservation>!
    private weak var contentSearchField: NSSearchField?

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
}

private extension DocumentationWindowController {
    func setupToolbar() {
        let toolbar = NSToolbar(identifier: "DocumentationWindowToolbar")
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self

        if let window = window {
            window.titlebarAppearsTransparent = true
            window.toolbarStyle = .automatic
            window.toolbar = toolbar
        }
    }

    @objc func openDocumentationInBrowser() {
        NSWorkspace.shared.open(documentation.url)
    }

    // MARK:- NotificationCenter observers

    @objc func observeViewerState() {
        guard let dvc = documentationViewController else { return }

        if dvc.viewerState != .ready {
            return
        }

        dvc.overridePreferencesExport()
        dvc.useNativeScrollbars(true)
    }

    @objc func observeDocumentTitle() {
        guard let dvc = documentationViewController else { return }
        self.window?.title = dvc.documentTitle ?? "DevDocs"
    }

    @objc func observeDocumentCategory() {
        guard let dvc = documentationViewController else { return }
        self.window?.subtitle = dvc.documentCategory ?? ""
    }

    @objc func observeDocumentURL() {
        guard let dvc = documentationViewController else { return }
        self.documentation.url = dvc.documentURL
    }

    @objc func observeMenuFindAction() {
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
    static let historyNavigation: NSToolbarItem.Identifier = NSToolbarItem.Identifier("HistoryNavigation")
    static let contentSearch: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ContentSearch")
    static let openInBrowser: NSToolbarItem.Identifier = NSToolbarItem.Identifier("OpenInBrowser")

    // Sub items
    static let navigateBack: NSToolbarItem.Identifier = NSToolbarItem.Identifier("NavigateBack")
    static let navigateForward: NSToolbarItem.Identifier = NSToolbarItem.Identifier("NavigateForward")
}

// MARK:- NSToolbarDelegate
extension DocumentationWindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .historyNavigation,
            .space,
            .flexibleSpace,
            .openInBrowser,
            .contentSearch
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.historyNavigation, .flexibleSpace, .openInBrowser, .contentSearch]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .historyNavigation:
            let backItem = NSToolbarItem(itemIdentifier: .navigateBack)
            backItem.label = NSLocalizedString("Back", comment: "Navigate back")
            backItem.toolTip = backItem.label
            backItem.isBordered = true
            backItem.image = NSImage(systemSymbolName: "chevron.backward",
                                     accessibilityDescription: NSLocalizedString("Navigate back", comment: ""))
            backItem.autovalidates = true

            let forwardItem = NSToolbarItem(itemIdentifier: .navigateForward)
            forwardItem.label = NSLocalizedString("Forward", comment: "Navigate forward")
            forwardItem.toolTip = forwardItem.label
            forwardItem.isBordered = true
            forwardItem.image = NSImage(systemSymbolName: "chevron.forward",
                                        accessibilityDescription: NSLocalizedString("Navigate forward", comment: ""))
            forwardItem.autovalidates = true

            let item = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
            item.label = NSLocalizedString("Back / Forward", comment: "History navigation")
            item.isNavigational = true
            item.subitems = [backItem, forwardItem]
            return item
        case .openInBrowser:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = NSLocalizedString("Open in Browser", comment: "Open current page in default system browser")
            item.toolTip = item.label
            item.isBordered = true
            item.image = NSImage(systemSymbolName: "safari",
                                 accessibilityDescription: NSLocalizedString("Open current page in default system browser", comment: ""))
            item.autovalidates = true
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
        case .historyNavigation:
            let itemGroup = item as! NSToolbarItemGroup
            for subitem in itemGroup.subitems {
                subitem.target = documentationViewController
                switch subitem.itemIdentifier {
                case .navigateBack:
                    subitem.action = #selector(DocumentationViewController.goBack)
                case .navigateForward:
                    subitem.action = #selector(DocumentationViewController.goForward)
                default:
                    break
                }
            }
        case .openInBrowser:
            item.target = self
            item.action = #selector(openDocumentationInBrowser)
        case .contentSearch:
            let searchItem = item as! NSSearchToolbarItem
            searchItem.searchField.delegate = documentationViewController
            searchItem.searchField.target = documentationViewController
            searchItem.searchField.action = #selector(DocumentationViewController.searchPageContents(_:))
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
        case .historyNavigation:
            let itemGroup = item as! NSToolbarItemGroup
            for subitem in itemGroup.subitems {
                subitem.target = nil
                subitem.action = nil
            }
        case .openInBrowser:
            item.target = nil
            item.action = nil
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
