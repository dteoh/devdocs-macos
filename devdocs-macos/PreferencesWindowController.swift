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

        let pageZoomPreference = GeneralPreferences.pageZoom
        let pageZoomMenu = NSMenu()
        var pageZoomSelection = 0
        for (i, option) in GeneralPreferences.pageZoomOptions.enumerated() {
            let menuItem = NSMenuItem()
            menuItem.title = option.0
            menuItem.representedObject = option.1
            pageZoomMenu.addItem(menuItem)

            if pageZoomPreference == option.1 {
                pageZoomSelection = i
            }
        }
        pageZoomPopup.menu = pageZoomMenu
        pageZoomPopup.selectItem(at: pageZoomSelection)

        if let recorderView = masShortcutRecorderView {
            recorderView.style = .texturedRect
            recorderView.associatedUserDefaultsKey = Summoner.prefsKey
        }
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
    }
}
