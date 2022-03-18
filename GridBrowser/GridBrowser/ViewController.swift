//
//  ViewController.swift
//  GridBrowser
//
//  Created by Abraham Abreu on 18/03/22.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - Actions

extension ViewController {
    
    @IBAction func urlEntered(_ sender: NSTextField) {
        print("urlEntered")
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        print("navigationclicked")
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        print("adjustrows")
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        print("adjustcolumns")
    }
}

