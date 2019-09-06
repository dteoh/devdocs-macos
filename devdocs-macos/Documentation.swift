import Foundation

class Documentation: NSObject {
    var url: URL!

    override init() {
        super.init()
        url = URL(string: "https://devdocs.io")
    }

    init(withURL url: URL) {
        self.url = url
    }
}
