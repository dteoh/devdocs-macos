import Cocoa

class SearchControlViewController: NSViewController {
    @IBOutlet weak var searchField: NSSearchField?
    weak var delegate: SearchControlDelegate?

    @IBAction func performSearch(sender: Any) {
        let searchTerm = (searchField?.stringValue ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if (searchTerm.isEmpty) {
            return
        }
        delegate?.search(term: searchTerm)
    }

    @IBAction func dismissSearch(sender: Any) {
        delegate?.dismiss()
    }
}

protocol SearchControlDelegate: class {
    func search(term: String)
    func dismiss()
}
