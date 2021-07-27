import Foundation
import DefaultsKit

private extension DefaultsKey {
    static let restoreDocs = Key<Bool>("restoreDocs")
    static let pageZoom = Key<Float>("pageZoom")
}

class GeneralPreferences {

    private init() {
    }

    class func restoreDefaults() {
        let defs = Defaults.shared
        defs.set(true, for: .restoreDocs)
        defs.set(1.0, for: .pageZoom)
    }

    class func shouldRestoreDocs() -> Bool {
        return Defaults.shared.get(for: .restoreDocs) ?? true
    }

    class func pageZoom() -> Float {
        return Defaults.shared.get(for: .pageZoom) ?? 1.0
    }

}
