import Cocoa
import WebKit

class DocumentationViewController: NSViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebsite()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        let userContentController = WKUserContentController()
        config.userContentController = userContentController;

        if let notMobileScript = readUserScript("not-mobile") {
            let notMobile = WKUserScript(source: notMobileScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(notMobile)
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

    // MARK:- WKNavigationDelegate

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(documentTitle ?? "no title")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(documentTitle ?? "no title")
    }

    // MARK:- JS integration

    func readUserScript(_ name: String) -> String? {
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
