//
//  WindowController.swift
//  GridBrowser
//
//  Created by Abraham Abreu on 18/03/22.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var addressEntry: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }

}
