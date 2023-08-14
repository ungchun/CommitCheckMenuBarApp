//
//  CommitCheckMenuBarAppApp.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import SwiftUI

@main
struct CommitCheckMenuBarAppApp: App {
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, ObservableObject, NSApplicationDelegate {
	
	@Published var statusItem: NSStatusItem?
	@Published var popover = NSPopover()
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		setUpMacMenu()
	}
	
	func setUpMacMenu() {
		popover.animates = true
		popover.behavior = .transient
		
		popover.contentViewController = NSViewController()
		popover.contentViewController?.view = NSHostingView(rootView: Home())
		
		popover.contentViewController?.view.window?.makeKey()
		
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		if let menuButton = statusItem?.button {
			menuButton.image = .init(systemSymbolName: "dollarsign.circle.fill", accessibilityDescription: nil)
			menuButton.action = #selector(menuButtonAction(sender:))
		}
	}
	
	@objc func menuButtonAction(sender: AnyObject) {
		if popover.isShown {
			popover.performClose(sender)
		} else {
			if let menuButton = statusItem?.button {
				popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .minY)
			}
		}
	}
}
