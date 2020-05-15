import Foundation
import DefaultsKit

private extension DefaultsKey {
    static let restoreDocs = Key<Bool>("restoreDocs")
}

class GeneralPreferences {

    private init() {
    }

    class func restoreDefaults() {
        Defaults.shared.set(true, for: .restoreDocs)
    }

    class func shouldRestoreDocs() -> Bool {
        return Defaults.shared.get(for: .restoreDocs) ?? true
    }

}
