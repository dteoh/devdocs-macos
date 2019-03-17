import Cocoa
import HotKey

struct PrefKeyCombo: Codable {
    let carbonKeyCode: UInt32
    let carbonModifiers: UInt32
}

extension DKDefaultsKey {
    static let summonKeys = DKKey<PrefKeyCombo>("summonKeys")
}

class Summoner {
    static let shared = Summoner();

    private var hotKey: HotKey!

    private init() {
    }

    func install() {
        let summonKeys = DKDefaults.shared.get(for: .summonKeys).map { combo in
            KeyCombo.init(carbonKeyCode: combo.carbonKeyCode, carbonModifiers: combo.carbonModifiers)
        } ?? KeyCombo.init(key: .space, modifiers: [.option])

        hotKey = HotKey.init(keyCombo: summonKeys)
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
