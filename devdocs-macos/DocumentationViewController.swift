import AppKit
import WebKit

public extension Notification.Name {
    static let DocumentTitleDidChange = Notification.Name(
        rawValue: "DocumentationViewControllerDocumentTitleDidChangeNotification")
    static let DocumentCategoryDidChange = Notification.Name(
        rawValue: "DocumentationViewControllerDocumentCategoryDidChangeNotification")
    static let DocumentURLDidChange = Notification.Name(
        rawValue: "DocumentationViewControllerDocumentURLDidChangeNotification")
    static let DocumentViewerStateDidChange = Notification.Name(
        rawValue: "DocumentationViewControllerViewerStateDidChangeNotification")
}

extension WKProcessPool {
    static let shared = WKProcessPool()
}

class DocumentationViewController: NSViewController {
    enum ViewerState {
        case blank
        case initializing
        case ready
    }

    weak var delegate: DocumentationViewDelegate?
    private var webView: WKWebView!

    private(set) var documentTitle: String? {
        didSet {
            NotificationCenter.default.post(name: .DocumentTitleDidChange, object: self)
        }
    }
    private(set) var documentCategory: String? {
        didSet {
            NotificationCenter.default.post(name: .DocumentCategoryDidChange, object: self)
        }
    }
    var documentURL: URL? {
        didSet {
            NotificationCenter.default.post(name: .DocumentURLDidChange, object: self)
        }
    }
    private(set) var viewerState: ViewerState = .blank {
        didSet {
            NotificationCenter.default.post(name: .DocumentViewerStateDidChange, object: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewerState = .initializing
        setupWebView()
        loadWebsite()
    }

    override func viewDidDisappear() {
        let ucc = webView.configuration.userContentController
        ucc.removeScriptMessageHandler(forName: "vcBus")
        ucc.removeAllUserScripts()
        super.viewDidDisappear()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool.shared
        config.websiteDataStore = WKWebsiteDataStore.default()

        let userContentController = WKUserContentController()
        config.userContentController = userContentController

        userContentController.add(self, name: "vcBus")

        if let integrationScript = readUserScript("integration") {
            let integration = WKUserScript(source: integrationScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(integration)
        }

        addFeatureScripts(userContentController)

        webView = WKWebView.init(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.wantsLayer = true
        webView.pageZoom = CGFloat(GeneralPreferences.pageZoom())
        // not possible to set "opaque" property, not possible to set backgroundColor...
        webView.setValue(false, forKey: "drawsBackground")

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func loadWebsite() {
        let request = URLRequest(url: documentURL!)
        webView.load(request)
    }

    // MARK:- Page search

    @objc func searchPageContents(_ sender: NSSearchField) {
        let argsBytes = try! JSONSerialization.data(withJSONObject: ["term": sender.stringValue])
        let args = NSString(data: argsBytes, encoding: String.Encoding.utf8.rawValue)! as String
        webView.evaluateJavaScript("search( (\(args))[\"term\"] );")
    }

    // MARK:- Navigation

    func canGoBack() -> Bool {
        return webView.backForwardList.backItem.map { _ in true } ?? false
    }

    func canGoForward() -> Bool {
        return webView.backForwardList.forwardItem.map { _ in true } ?? false
    }

    @objc func goBack() {
        webView.evaluateJavaScript("window.history.back();");
    }

    @objc func goForward() {
        webView.evaluateJavaScript("window.history.forward();");
    }

    // MARK:- JS integration

    func useNativeScrollbars(_ using: Bool) {
        if using {
            webView.evaluateJavaScript("useNativeScrollbars(true);")
        } else {
            webView.evaluateJavaScript("useNativeScrollbars(false);")
        }
    }

    func overridePreferencesExport() {
        webView.evaluateJavaScript("overridePreferencesExport();")
    }

    private func addFeatureScripts(_ controller: WKUserContentController) {
        if let pageObserverScript = readUserScript("page-observer") {
            let pageObserver = WKUserScript(source: pageObserverScript,
                                            injectionTime: .atDocumentEnd,
                                            forMainFrameOnly: true)
            controller.addUserScript(pageObserver)
        }

        if let pageSearchScript = readUserScript("page-search") {
            let pageSearch = WKUserScript(source: pageSearchScript,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            controller.addUserScript(pageSearch)
        }

        if let uiSettingsScript = readUserScript("ui-settings") {
            let uiSettings = WKUserScript(source: uiSettingsScript,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            controller.addUserScript(uiSettings)
        }
    }

    private func readUserScript(_ name: String) -> String? {
        guard let scriptPath = Bundle.main.path(forResource: name, ofType: "js", inDirectory: "user-scripts") else {
            return nil
        }
        do {
            return try String(contentsOfFile: scriptPath)
        } catch {
            return nil
        }
    }

    private func handleAfterInit() {
        self.viewerState = .ready
    }

    private func handleTitleNotification(_ args: [AnyHashable: Any]) {
        if let topic = args["topic"] as! String? {
            self.documentTitle = topic
        } else if let title = args["title"] as! String? {
            let suffix = " — DevDocs"
            if title.hasSuffix(suffix) {
                self.documentTitle = title.replacingOccurrences(of: suffix, with: "")
            } else {
                self.documentTitle = title
            }
        }

        self.documentCategory = args["doc"] as! String?
    }

    private func handleLocationNotification(_ args: [AnyHashable: Any]) {
        guard let location = args["location"] as! String? else {
            return
        }
        self.documentURL = URL(string: location)
    }

    private func handleAppReboot() {
        webView.reload()
    }

    private func handleExportPreferences(_ args: [AnyHashable: Any]) {
        guard let preferences = args["preferences"] as! String? else {
            return
        }
        delegate?.savePreferencesToFile(preferences)
    }
}

protocol DocumentationViewDelegate: class {
    typealias OpenPanelParameters = WKOpenPanelParameters
    func selectFileToOpen(_ parameters: OpenPanelParameters, completionHandler: @escaping ([URL]?) -> Void)
    func savePreferencesToFile(_ preferences: String)
}

// MARK:- WKUIDelegate
extension DocumentationViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let requestURL = navigationAction.request.url else {
            return nil
        }

        if let host = requestURL.host, host == "devdocs.io" {
            DocumentationWindows.shared.newWindow(forURL: requestURL)
            return nil
        }

        if let scheme = requestURL.scheme {
            switch scheme {
            case "http", "https", "mailto":
                NSWorkspace.shared.open(requestURL)
            default:
                break;
            }
        }

        return nil
    }

    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        delegate?.selectFileToOpen(parameters, completionHandler: completionHandler)
    }
}

// MARK:- WKNavigationDelegate
extension DocumentationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let ucc = webView.configuration.userContentController
        addFeatureScripts(ucc)
    }
}

// MARK:- WKScriptMessageHandler
extension DocumentationViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let msg = message.body as? [AnyHashable: Any] else {
            return
        }
        guard let type = msg["type"] as? String else {
            return
        }
        switch type {
        case "afterInit":
            handleAfterInit()
        case "titleNotification":
            guard let args = msg["args"] as? [AnyHashable: Any] else {
                return
            }
            handleTitleNotification(args)
        case "locationNotification":
            guard let args = msg["args"] as? [AnyHashable: Any] else {
                return
            }
            handleLocationNotification(args)
        case "appReboot":
            handleAppReboot()
        case "exportPreferences":
            guard let args = msg["args"] as? [AnyHashable: Any] else {
                return
            }
            handleExportPreferences(args)
        default:
            return
        }
    }
}

// MARK:- NSSearchFieldDelegate
extension DocumentationViewController: NSSearchFieldDelegate {
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        webView.evaluateJavaScript("resetSearch();")
    }
}

// MARK:- NSUserInterfaceValidations
extension DocumentationViewController: NSUserInterfaceValidations {
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(goBack) {
            return canGoBack()
        }
        if item.action == #selector(goForward) {
            return canGoForward()
        }
        return false
    }
}
