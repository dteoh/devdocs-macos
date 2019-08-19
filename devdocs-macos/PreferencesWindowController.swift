import Cocoa
import MASShortcut

class PreferencesWindowController: NSWindowController {
    @IBOutlet weak var masShortcutRecorderView: MASShortcutView?;

    static let shared = PreferencesWindowController()

    private convenience init() {
        self.init(windowNibName: "PreferencesWindowController")
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        if let recorderView = masShortcutRecorderView {
            recorderView.style = .texturedRect
            recorderView.associatedUserDefaultsKey = Summoner.prefsKey
        }
    }

    @IBAction func restoreDefaults(sender: Any) {
        if let recorderView = masShortcutRecorderView {
            recorderView.shortcutValue = Summoner.defaultShortcut
        }
    }
}
