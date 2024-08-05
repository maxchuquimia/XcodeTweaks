//
//  AppDelegate.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showMainWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func showMainWindow() {
        if window == nil {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 650, height: 400),
                styleMask: [.titled, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, 
                defer: false
            )
            window?.title = "XcodeTweaks"
            window?.center()
            window?.setFrameAutosaveName("Main Window")
            window?.contentView = NSHostingView(rootView: MainWindowView())
        }

        window?.makeKeyAndOrderFront(nil)
    }

    @IBAction func showSettings(sender: AnyObject?) {
        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 450),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered, 
                defer: false
            )

            settingsWindow?.title = "XcodeTweaks Settings"
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("Settings Window")
            settingsWindow?.contentView = NSHostingView(rootView: SettingsWindowView())
        }

        settingsWindow?.makeKeyAndOrderFront(self)
    }

}
