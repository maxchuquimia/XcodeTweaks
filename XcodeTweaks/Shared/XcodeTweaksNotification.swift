//
//  XcodeTweaksNotification.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation

/// Defines the payload sent from Xcode Behaviours to XcodeTweaks
struct XcodeTweaksNotification: Codable {

    struct Environment: Codable {
        let projectName: String?
        let projectPath: String?
        let workspacePath: String?
        let xcodeDeveloperDirectory: String?

        init(projectName: String?, projectPath: String?, workspacePath: String?, xcodeDeveloperDirectory: String?) {

            if let projectName = projectName {
                self.projectName = projectName
            } else {
                // Project Name is unavaible in the environment when building a Swift Package, so try to
                // determine a name from the project path
                self.projectName = workspacePath?
                    .components(separatedBy: "/.swiftpm")
                    .first?
                    .components(separatedBy: "/")
                    .last
            }
            self.projectPath = projectPath
            self.workspacePath = workspacePath
            self.xcodeDeveloperDirectory = xcodeDeveloperDirectory
        }
    }

    let alertMessage: IDEAlertMessage
    let environment: Environment

}

extension XcodeTweaksNotification.Environment {

    var projectLocation: XcodeProjectState.Location {
        projectPath ?? workspacePath ?? projectName ?? "Unknown"
    }

    var projectNameWithoutExtension: String? {
        projectName?
            .replacingOccurrences(of: ".xcodeproj", with: "")
            .replacingOccurrences(of: ".xcworkspace", with: "")
    }

}
