import Cocoa
import WebKit

class DocumentationViewController: NSViewController, WKNavigationDelegate {

    var webView: WKWebView {
        return view as! WKWebView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebsite()
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
