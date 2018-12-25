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

    var documentTitle: String? {
        var title: String?
        webView.evaluateJavaScript("$(\"head title\").innerText") { (result, error) in
            if let result = result as? String {
                title = result
            }
        }
        return title;
    }

}
