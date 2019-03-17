//
//  PreferencesViewController.swift
//  DevDocs
//
//  Created by Jeff Hanbury on 17/03/19.
//  Copyright © 2019 Douglas Teoh. All rights reserved.
//

import Cocoa
import MASShortcut

class PreferencesViewController: NSViewController {

    @IBOutlet weak var activateAppShortcut: MASShortcutView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initShortcuts()
    }
}

// Implement MASShortcut
extension PreferencesViewController {
    func initShortcuts() {
        // Choose the preferred visual style.
        activateAppShortcut.style = MASShortcutViewStyleTexturedRect
        
        // Tell MASShortcut which userdefaults key to auto-save into.
        activateAppShortcut.associatedUserDefaultsKey = Preferences.Key.shortcutActivateApp
    }
}
