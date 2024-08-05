//
//  main.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation
import AppKit

if CommandLine.arguments.contains("--cli") {
    DirectRun.handle()
} else {
    let appDelegate = AppDelegate()
    let application = NSApplication.shared
    application.delegate = appDelegate

    print("Running as standalone app")
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}

