import Foundation
import DefaultsKit

private extension DefaultsKey {
    static let locations = Key<[URL]>("locations")
}

class Storage: NSObject {

    private override init() {
    }

    class func setLocations(_ locations: [URL]) {
        let defaults = Defaults.shared
        defaults.set(locations, for: .locations)
    }

    class func getLocations() -> [URL]? {
        return Defaults.shared.get(for: .locations)
    }

}
