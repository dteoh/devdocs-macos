import Cocoa
import MASShortcut

class Summoner {
    static let shared = Summoner();

    private let prefsKey = "summonKeys";

    private init() {
        // Register MASShortcut defaults.
        let modifiers = NSEvent.ModifierFlags([.option])
        let shortcut = MASShortcut(keyCode: UInt(kVK_Space), modifierFlags: modifiers.rawValue)
        MASShortcutBinder.shared().registerDefaultShortcuts([prefsKey : shortcut as Any])
    }

    func install() {
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: prefsKey, toAction: {
            self.hotKeyPressed()
        })
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
