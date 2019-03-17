import Cocoa
import HotKey
import MASShortcut


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var hotKey: HotKey!
    private lazy var preferencesController: NSWindowController? = createPreferencesWindow()

    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentationWindows.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupHotKey()
        DocumentationWindows.shared.restore()
        
        Preferences.registerDefaults()
        bindShortcuts()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DocumentationWindows.shared.persist()
    }

    @IBAction func newTab(sender: Any) {
        DocumentationWindows.shared.newWindow()
    }

    private func setupHotKey() {
        hotKey = HotKey(key: .space, modifiers: [.option])
        hotKey.keyDownHandler = hotKeyPressed
    }

    private func hotKeyPressed() {
        NSApp.activate(ignoringOtherApps: true)
        DocumentationWindows.shared.newWindowIfNoWindow()
    }
    
    // MARK: - Preferences
    
    private func createPreferencesWindow()->NSWindowController? {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? NSWindowController
    }
    
    @IBAction func showPreferences(_ sender: NSMenuItem) {
        guard let preferencesController = preferencesController else {
                return
        }
        
        preferencesController.showWindow(sender)
    }
    
}

// Shortcut actions.
extension AppDelegate {
    func bindShortcuts() {
        // "activate-app" shortcut.
        MASShortcutBinder.shared().bindShortcut(withDefaultsKey: Preferences.Key.shortcutActivateApp) {
            if (NSApp.isActive) {
                NSApp.hide(self)
            }
            else {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
