//
//  WindowController.swift
//  GridBrowser
//
//  Created by Abraham Abreu on 18/03/22.
//

import Cocoa

class WindowController: NSWindowController {
    
    // MARK: - Properties

    @IBOutlet var addressEntry: NSTextField!
    @IBOutlet var reloadButton: NSButton!
    
    // MARK: - Initialization
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }
    
    // MARK: - TouchBar Trigger esc button.

    override func cancelOperation(_ sender: Any?) {
        window?.makeFirstResponder(self.contentViewController)
    }
}
