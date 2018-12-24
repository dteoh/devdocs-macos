import Cocoa
import WebKit

class DocumentationController: NSWindowController {
    @IBOutlet weak var webView: WKWebView?

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("DocumentationWindow")
    }

    override func windowDidLoad() {
        loadWebsite()
    }

    private func loadWebsite() {
        if let web = webView {
            let url = URL(string: "https://devdocs.io")
            let request = URLRequest(url: url!)
            web.load(request)
        }
    }
}
