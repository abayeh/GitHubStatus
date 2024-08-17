//
//  GitHubStatusApp.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Cocoa
import SwiftUI

@main
struct GitHubStatusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            // Empty scene, no main window
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var componentViewModel = ComponentViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Share the app delegate instance
        AppDelegate.shared = self

        // Create the status item in the menu bar
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Experiment
        // Status bar icon SwiftUI view & a hosting view.
        let iconSwiftUI = ZStack(alignment:.center) {
            Text("GH")
                .font(.footnote)
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 18, height: 18)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .center)
                .padding(.trailing, 5)
        }

        let iconView = NSHostingView(rootView: iconSwiftUI)
        iconView.frame = NSRect(x: 0, y: 0, width: 30, height: 18)
        
        if let button = self.statusItem?.button {
            button.addSubview(iconView)
            button.frame = iconView.frame
            button.action = #selector(togglePopover(_:))
        } else {
            print("Failed to create status item button")  // Debug print to confirm button creation
        }

        // Set up the popover content
        let hostingController = NSHostingController(rootView: GitHubView())
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 200, height: 530)
        
        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 200, height: 530)
        popover.behavior = .transient
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = self.statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
