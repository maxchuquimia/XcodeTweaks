//
//  DirectRun.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation

enum DirectRun {

    static func handle() {
        guard let alertMessage = ProcessInfo.processInfo.environment["IDEAlertMessage"] else {
            print("No IDEAlertMessage found in environment.")
            return
        }

        guard let alertMessage = IDEAlertMessage(rawValue: alertMessage) else {
            print("Unknown or unused IDEAlertMessage '\(alertMessage)' found in environment.")
            return
        }

        print("Handling \(alertMessage)")

        let environment = XcodeTweaksNotification.Environment(
            projectName: ProcessInfo.processInfo.environment["XcodeProject"],
            projectPath: ProcessInfo.processInfo.environment["XcodeProjectPath"],
            workspacePath: ProcessInfo.processInfo.environment["XcodeWorkspacePath"],
            xcodeDeveloperDirectory: ProcessInfo.processInfo.environment["XcodeDeveloperDirectory"]
        )

        Communication.post(notification: XcodeTweaksNotification(alertMessage: alertMessage, environment: environment))

        print("Sent \(environment)")
    }

}
