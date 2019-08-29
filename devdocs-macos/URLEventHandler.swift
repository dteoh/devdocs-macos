import Cocoa

class URLEventHandler {

    static let shared = URLEventHandler()

    private init() {
    }

    func install() {
        let manager = NSAppleEventManager.shared()
        manager.setEventHandler(self,
                                andSelector: #selector(handleGetURLEvent(event:replyEvent:)),
                                forEventClass: AEEventClass(kInternetEventClass),
                                andEventID: AEEventID(kAEGetURL))
    }

    @objc
    private func handleGetURLEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))
            .flatMap { event in event.stringValue }
            .flatMap { str in URL(string: str) }

        guard let command = url?.host else {
            return
        }

        switch command {
        case "search":
            guard let term = url?.getQueryString(parameter: "term") else {
                return
            }

            let q = (
                url?.getQueryString(parameter: "doc").map({ doc in "\(doc) \(term)" })
                ?? term
            ).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)

            guard let searchURL = URL(string: "https://devdocs.io/#q=\(q ?? "")") else {
                return
            }

            NSApp.activate(ignoringOtherApps: true)
            DocumentationWindows.shared.newWindow(forURL: searchURL)
        case "newWindow":
            NSApp.activate(ignoringOtherApps: true)
            DocumentationWindows.shared.newWindow()
        case "devdocs.io":
            NSApp.activate(ignoringOtherApps: true)
            DocumentationWindows.shared.newWindow(forURL: url!)
        default:
            return
        }
    }
}

// From: https://gist.github.com/gillesdemey/509bb8a1a8c576ea215a#gistcomment-2568338
extension URL {
    func getQueryString(parameter: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == parameter }?
            .value
    }
}
