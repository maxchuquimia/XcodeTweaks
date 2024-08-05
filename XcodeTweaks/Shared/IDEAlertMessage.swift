//
//  IDEAlertMessage.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 23/6/2024.
//

import Foundation

enum IDEAlertMessage: String, Codable {
    case buildStarted = "Build Started"
    case buildSucceeded = "Build Succeeded"
    case buildFailed = "Build Failed"
    case testSucceeded = "Test Succeeded"
    case testStarted = "Test Started"
    case testFailed = "Test Failed"
}
