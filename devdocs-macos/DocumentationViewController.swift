import Cocoa
import WebKit

class DocumentationViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler {

    private var webView: WKWebView!

    @objc dynamic var documentTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebsite()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        let userContentController = WKUserContentController()
        config.userContentController = userContentController;

        userContentController.add(self, name: "vcBus");

        if let notMobileScript = readUserScript("not-mobile") {
            let notMobile = WKUserScript(source: notMobileScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(notMobile)
        }

        if let titleObserverScript = readUserScript("title-observer") {
            let titleObserver = WKUserScript(source: titleObserverScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(titleObserver)
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
        let url = URL(string: "https://devdocs.io")
        let request = URLRequest(url: url!)
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
        guard let args = msg["args"] as? [AnyHashable: Any] else {
            return
        }
        switch type {
        case "titleNotification":
            self.documentTitle = args["title"] as! String?
        default:
            return
        }
    }

    // MARK:- JS integration

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

}
