//
//  ViewController.swift
//  GridBrowser
//
//  Created by Abraham Abreu on 18/03/22.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    // MARK: - Properties
    
    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        rows.addArrangedSubview(column)
    }
}

// MARK: - Private

private extension ViewController {
    
    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        if selectedWebView == nil {
            select(webView: webView)
        }
        return webView
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.systemBlue.cgColor
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
}

// MARK: - Objc Methods

@objc extension ViewController {
    
    func webViewClicked(recognizer: NSClickGestureRecognizer) {
        guard let newSelectedView = recognizer.view as? WKWebView else { return }
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        select(webView: newSelectedView)
    }
    
    func selectAddressEntry() {
        if let windowController = view.window?.windowController as? WindowController {
            windowController.window?.makeFirstResponder(windowController.addressEntry)
        }
    }
}

// MARK: - Actions

extension ViewController {
    
    @IBAction func urlEntered(_ sender: NSTextField) {
        guard let selected = selectedWebView else { return }
        if let url = URL(string: sender.stringValue) {
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        guard let selected = selectedWebView else { return }
        
        if sender.selectedSegment == 0 {
            selected.goBack()
        } else {
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            let viewArray = (0..<columnCount).map { _ in makeWebView() }
            let row = NSStackView(views: viewArray)
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            guard rows.arrangedSubviews.count > 1 else { return }
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            for cell in rowToRemove.arrangedSubviews {
                cell.removeFromSuperview()
            }
            rows.removeArrangedSubview(rowToRemove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            for case let row as NSStackView in rows.arrangedSubviews {
                row.addArrangedSubview(makeWebView())
            }
        } else {
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            guard firstRow.arrangedSubviews.count > 1 else { return }
        
            for case let row as NSStackView in rows.arrangedSubviews {
                if let last = row.arrangedSubviews.last {
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
    @IBAction func reloadWebPage(_ sender: NSButton) {
        guard let selected = selectedWebView else { return }
        if selected.isLoading {
            selected.stopLoading()
        } else {
            selected.reload()
        }
    }
}

// MARK: - WKNavigation Delegate

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        if let windowController = view.window?.windowController as? WindowController {
            windowController.reloadButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard webView == selectedWebView else { return }
        if let windowController = view.window?.windowController as? WindowController {
            windowController.reloadButton.image = NSImage(named: NSImage.refreshTemplateName)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        if let windowController = view.window?.windowController as? WindowController {
            windowController.reloadButton.image = NSImage(named: NSImage.refreshTemplateName)
        }
    }
}

// MARK: - Gesture Delegate
extension ViewController: NSGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer == selectedWebView {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Touch Bar

extension NSTouchBarItem.Identifier {
    static let navigation = NSTouchBarItem.Identifier("com.slekens.grid-browser.navigation")
    static let enterAddress = NSTouchBarItem.Identifier("com.slekens.grid-browser.enterAddress")
    static let sharingPicker = NSTouchBarItem.Identifier("com.slekens.grid-browser.sharingPicker")
    static let adjustGrid = NSTouchBarItem.Identifier("com.slekens.grid-browser.adjustGrid")
    static let adjustRows = NSTouchBarItem.Identifier("com.slekens.grid-browser.adjustRows")
    static let adjustCols = NSTouchBarItem.Identifier("com.slekens.grid-browser.adjustCols")
}

extension ViewController: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.enterAddress:
            let button = NSButton(title: "Enter a URL", target: self, action: #selector(selectAddressEntry))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = button
            return customTouchBarItem
        case NSTouchBarItem.Identifier.navigation:
            let back = NSImage(named: NSImage.touchBarGoBackTemplateName)!
            let forward = NSImage(named: NSImage.touchBarGoForwardTemplateName)!
            let segmentedControl = NSSegmentedControl(images: [back, forward], trackingMode: .momentary, target: self, action: #selector(navigationClicked))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = segmentedControl
            return customTouchBarItem
        case NSTouchBarItem.Identifier.sharingPicker:
            let picker = NSSharingServicePickerTouchBarItem(identifier: identifier)
            picker.delegate = self
            return picker
        case NSTouchBarItem.Identifier.adjustRows:
            let control = NSSegmentedControl(labels: ["Add Row", "Remove Row"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustRows))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Rows"
            customTouchBarItem.view = control
            return customTouchBarItem
        case NSTouchBarItem.Identifier.adjustCols:
            let control = NSSegmentedControl(labels: ["Add Column", "Remove Column"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustColumns))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Columns"
            customTouchBarItem.view = control
            return customTouchBarItem
        case NSTouchBarItem.Identifier.adjustGrid:
            let popover = NSPopoverTouchBarItem(identifier: identifier)
            popover.collapsedRepresentationLabel = "Grid"
            popover.customizationLabel = "Adjust Grid"
            popover.popoverTouchBar = NSTouchBar()
            popover.popoverTouchBar.delegate = self
            popover.popoverTouchBar.defaultItemIdentifiers = [.adjustRows, .adjustCols]
            return popover
        default:
            return nil
        }
    }
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.slekens.grid-browser")
        touchBar.delegate = self
        
        touchBar.defaultItemIdentifiers = [.navigation, .adjustGrid, .enterAddress, .sharingPicker]
        touchBar.principalItemIdentifier = .enterAddress
        touchBar.customizationAllowedItemIdentifiers = [.sharingPicker, .adjustGrid, .adjustCols, .adjustRows]
        touchBar.customizationRequiredItemIdentifiers = [.enterAddress]
        
        return touchBar
    }
}

extension ViewController: NSSharingServicePickerTouchBarItemDelegate {
    
    @available(OSX 10.12.2, *)
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        guard let webView = selectedWebView else { return [] }
        guard let url = webView.url?.absoluteString else { return [] }
        return [url]
    }
}
