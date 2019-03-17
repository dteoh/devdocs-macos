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
        print(command)
    }
}
