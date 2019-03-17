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
            recorderView.associatedUserDefaultsKey = Summoner.prefsKey
        }
    }
}
