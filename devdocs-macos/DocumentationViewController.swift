import Cocoa
import WebKit

class DocumentationViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @objc enum ViewerState: Int {
        case blank
        case initializing
        case ready
    }

    var currentURL: URL?
    private var webView: WKWebView!

    @objc dynamic var documentTitle: String?
    @objc dynamic var viewerState: ViewerState = .blank

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewerState = .initializing
        setupWebView()
        loadWebsite()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        let userContentController = WKUserContentController()
        config.userContentController = userContentController;

        userContentController.add(self, name: "vcBus");

        if let integrationScript = readUserScript("integration") {
            let integration = WKUserScript(source: integrationScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(integration)
        }

        if let titleObserverScript = readUserScript("title-observer") {
            let titleObserver = WKUserScript(source: titleObserverScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(titleObserver)
        }

        if let uiSettingsScript = readUserScript("ui-settings") {
            let uiSettings = WKUserScript(source: uiSettingsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(uiSettings)
        }

        webView = WKWebView.init(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.wantsLayer = true

        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    private func loadWebsite() {
        let request = URLRequest(url: currentURL!)
        webView.load(request)
    }

    // MARK:- WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let msg = message.body as? [AnyHashable: Any] else {
            return
        }
        guard let type = msg["type"] as? String else {
            return
        }
        switch type {
        case "afterInit":
            handleAfterInit();
        case "titleNotification":
            guard let args = msg["args"] as? [AnyHashable: Any] else {
                return
            }
            handleTitleNotification(args);
        default:
            return
        }
    }

    // MARK:- JS integration

    func useDarkMode(_ using: Bool) {
        if using {
            webView.evaluateJavaScript("useDarkMode(true);")
        } else {
            webView.evaluateJavaScript("useDarkMode(false);")
        }
    }

    func useNativeScrollbars(_ using: Bool) {
        if using {
            webView.evaluateJavaScript("useNativeScrollbars(true);")
        } else {
            webView.evaluateJavaScript("useNativeScrollbars(false);")
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
        guard let title = args["title"] as! String? else {
            return
        }
        let suffix = " — DevDocs"
        if title.hasSuffix(suffix) {
            self.documentTitle = title.replacingOccurrences(of: suffix, with: "")
        } else {
            self.documentTitle = title
        }
    }

}
