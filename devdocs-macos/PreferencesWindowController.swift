import AppKit
import MASShortcut

class PreferencesWindowController: NSWindowController {
    @IBOutlet weak var masShortcutRecorderView: MASShortcutView?
    @IBOutlet weak var pageZoomPopup: NSPopUpButton!

    static let shared = PreferencesWindowController()

    private convenience init() {
        self.init(windowNibName: "PreferencesWindowController")
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        let pageZoomMenu = NSMenu()
        for option in GeneralPreferences.pageZoomOptions {
            let menuItem = NSMenuItem()
            menuItem.title = option.0
            menuItem.representedObject = option.1
            pageZoomMenu.addItem(menuItem)
        }
        pageZoomPopup.menu = pageZoomMenu

        if let recorderView = masShortcutRecorderView {
            recorderView.style = .texturedRect
            recorderView.associatedUserDefaultsKey = Summoner.prefsKey
        }

        updateUI()
    }

    @IBAction func pageZoomPopupDidChangeValue(_ sender: Any) {
        if let zoomLevel = pageZoomPopup.selectedItem?.representedObject as? Float {
            GeneralPreferences.pageZoom = zoomLevel
        }
    }

    @IBAction func restoreDefaults(_ sender: Any) {
        if let recorderView = masShortcutRecorderView {
            recorderView.shortcutValue = Summoner.defaultShortcut
        }
        GeneralPreferences.restoreDefaults()
        updateUI()
    }
}

private extension PreferencesWindowController {
    private func updateUI() {
        let pageZoomPreference = GeneralPreferences.pageZoom
        for menuItem in pageZoomPopup.menu?.items ?? [] {
            if let value = menuItem.representedObject as? Float, value == pageZoomPreference {
                pageZoomPopup.select(menuItem)
                break
            }
        }
    }
}
