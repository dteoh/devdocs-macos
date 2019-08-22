import Cocoa

class SearchControlViewController: NSViewController {
    @IBOutlet weak var searchField: NSSearchField?
    weak var delegate: SearchControlDelegate?

    init() {
        super.init(nibName: NSNib.Name("SearchControlView"), bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    @IBAction func performSearch(_ sender: Any) {
        let searchTerm = (searchField?.stringValue ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if (searchTerm.isEmpty) {
            return
        }
        delegate?.search(term: searchTerm)
    }

    @IBAction func dismissSearch(_ sender: Any) {
        delegate?.dismiss()
    }
}

protocol SearchControlDelegate: class {
    func search(term: String)
    func dismiss()
}
