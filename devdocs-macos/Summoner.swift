import Cocoa
import HotKey;

class Summoner {
    static let shared = Summoner();

    private var hotKey: HotKey!

    private init() {
    }

    func install() {
        hotKey = HotKey(key: .space, modifiers: [.option])
        hotKey.keyDownHandler = hotKeyPressed
    }

    private func hotKeyPressed() {
        if NSApp.isActive {
            NSApp.hide(self)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            DocumentationWindows.shared.newWindowIfNoWindow()
        }
    }
}
