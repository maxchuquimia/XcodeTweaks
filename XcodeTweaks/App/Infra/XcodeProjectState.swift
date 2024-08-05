//
//  Project.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 2/7/2024.
//

import Foundation

// An intentionally mutable object to hold state related to an Xcode project
final class XcodeProjectState {

    typealias Location = String
    static let maxRetries = 3

    var location: Location // Used as an identifier as two projects can't exist at the exact same file location
    var lastBuildSuccessDate: Date = Date()
    var numberOfRetriesRemaining: Int = XcodeProjectState.maxRetries

    init(location: Location) {
        self.location = location
    }

}
