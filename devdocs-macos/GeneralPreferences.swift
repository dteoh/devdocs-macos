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

    static var pageZoom: Float {
        get {
            return Defaults.shared.get(for: .pageZoom) ?? 1.0
        }

        set {
            Defaults.shared.set(newValue, for: .pageZoom)
        }
    }

    static let pageZoomOptions: [(String, Float)] = [
        ("50%", 0.5),
        ("75%", 0.75),
        ("100%", 1.0),
        ("125%", 1.25),
        ("133%", 1.33),
        ("150%", 1.5),
        ("166%", 1.66),
        ("175%", 1.75),
        ("200%", 2.0),
        ("250%", 2.5),
        ("300%", 3.0),
    ]
}
