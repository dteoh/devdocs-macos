import Cocoa

class SearchControlViewController: NSViewController {
    weak var delegate: SearchControlDelegate?
    @IBOutlet weak var searchField: NSSearchField!

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

    override func viewDidAppear() {
        super.viewDidAppear()
        searchField?.becomeFirstResponder()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        delegate?.dismiss()
    }

    func activate() {
        self.view.isHidden = false
        searchField?.becomeFirstResponder()
    }

    @IBAction func performSearch(_ searchField: NSSearchField) {
        searchFieldDidStartSearching(searchField)
    }

    @IBAction func dismissSearch(_ sender: Any) {
        self.view.isHidden = true
    }
}

extension SearchControlViewController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ searchField: NSSearchField) {
        let searchTerm = searchField.stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if (searchTerm.isEmpty) {
            return
        }
        delegate?.search(term: searchTerm)
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.view.isHidden = true
    }
}

protocol SearchControlDelegate: class {
    func search(term: String)
    func dismiss()
}
