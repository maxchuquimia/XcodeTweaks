//
//  NSRunningApplication.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation
import AppKit

extension NSRunningApplication {

    static var xcode: NSRunningApplication? {
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dt.Xcode").first
    }

}
