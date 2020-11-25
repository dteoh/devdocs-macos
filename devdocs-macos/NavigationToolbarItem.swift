import AppKit

class NavigationToolbarItem: NSToolbarItem {
    var navigationDelegate: NavigationToolbarItemDelegate?

    override func validate() {
        if let delegate = navigationDelegate {
            self.isEnabled = delegate.canNavigate(self)
        }
    }
}

protocol NavigationToolbarItemDelegate: class {
    func canNavigate(_ item: NavigationToolbarItem) -> Bool
    func setTargetAndAction(_ button: NSButton, forItem item: NavigationToolbarItem)
}
