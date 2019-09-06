import AppKit
import MASShortcut

class Summoner {
    static let shared = Summoner()

    static let prefsKey = "summonKeys"

    static var defaultShortcut: MASShortcut {
        let modifiers = NSEvent.ModifierFlags([.option])
        return MASShortcut(keyCode: kVK_Space, modifierFlags: modifiers)
    }

    private init() {
        if let binder = MASShortcutBinder.shared() {
            binder.registerDefaultShortcuts([Summoner.prefsKey : Summoner.defaultShortcut])
        }
    }

    func install() {
        if let binder = MASShortcutBinder.shared(){
            binder.bindShortcut(withDefaultsKey: Summoner.prefsKey) {
                self.hotKeyPressed()
            }
        }
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
