//
//  Preferences.swift
//  DevDocs
//
//  Created by Jeff Hanbury on 17/03/19.
//  Copyright © 2019 Douglas Teoh. All rights reserved.
//
//  Inspired by Iina
//

import Cocoa
import MASShortcut


struct Preferences {
    
    // MARK: - Keys
    
    struct Key {
        /** Shortcuts */
        static let shortcutActivateApp = "shortcutActivateApp"
    }
    
    
    static func registerDefaults() {
        // Register the shortcut default value. Google Events.h for values.
        let modifiers = NSEvent.ModifierFlags([.option])
        let shortcut = MASShortcut(keyCode: UInt(kVK_Space), modifierFlags: modifiers.rawValue
        )
    MASShortcutBinder.shared().registerDefaultShortcuts([Preferences.Key.shortcutActivateApp : shortcut as Any])
    }
    
}
