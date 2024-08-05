//
//  LogInspector.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 23/6/2024.
//

import Foundation
import XCLogParser

@MainActor
final class LogInspector {

    enum BuildInformation: CaseIterable {
        case canBuildAgainToContinue
        case containsMultipleReferencesWithSameGUID
        case receivedMultipleTargetEndedMessagesForTargetID
        case targetIDNotFoundInActiveTargets
        case hasTestResultsFile
        case hasLaunchResultsFile
        case codesignFailedWithNonZeroExitCode

        // unknown error while handling message: unknownSession(handle: -> restart xcode

        var buildLogSearchRegex: String? {
            switch self {
            case .canBuildAgainToContinue:
                return "Build again to continue"
            case .containsMultipleReferencesWithSameGUID:
                return "contains multiple references with the same GUID"
            case .receivedMultipleTargetEndedMessagesForTargetID:
                return "received multiple target ended messages for target ID"
            case .targetIDNotFoundInActiveTargets:
                return "targetID \\(\\d+\\) not found in _activeTargets"
            case .codesignFailedWithNonZeroExitCode:
                return "CodeSign failed with a nonzero exit code"
            case .hasTestResultsFile, .hasLaunchResultsFile:
                return nil
            }
        }

        var localizedName: String? {
            switch self {
            case .canBuildAgainToContinue:
                return "Build again to continue"
            case .containsMultipleReferencesWithSameGUID:
                return "Contains multiple references with the same GUID"
            case .receivedMultipleTargetEndedMessagesForTargetID:
                return "Received multiple target ended messages for target ID"
            case .targetIDNotFoundInActiveTargets:
                return "Target ID not found in active targets"
            case .codesignFailedWithNonZeroExitCode:
                return "CodeSign failed with a nonzero exit code"
            case .hasTestResultsFile, .hasLaunchResultsFile:
                return nil
            }
        }
    }

    let buildDirectory: URL
    let testDirectory: URL
    let launchDirectory: URL
    let minimumDate: Date

    init(environment: XcodeTweaksNotification.Environment, minimumDate: Date) throws {
        self.minimumDate = minimumDate
        let logOptions = LogOptions(
            projectName: environment.projectName ?? "",
            xcworkspacePath: environment.projectPath ?? "",
            xcodeprojPath: environment.projectPath ?? "",
            derivedDataPath: "",
            logManifestPath: ""
        )

        let logFinder = LogFinder()
        // e.g. /Users/me/Library/Developer/Xcode/DerivedData/Project-UUID/Logs/Build/LogStoreManifest.plist
        var discoveredDirectory = try logFinder.findLogManifestWithLogOptions(logOptions)
        discoveredDirectory.deleteLastPathComponent() // Remove LogStoreManifest.plist
        self.buildDirectory = discoveredDirectory
        discoveredDirectory.deleteLastPathComponent() // Remove Build
        self.testDirectory = discoveredDirectory.appending(component: "Test", directoryHint: .isDirectory)
        self.launchDirectory = discoveredDirectory.appending(component: "Launch", directoryHint: .isDirectory)
    }

    func buildInformation() async throws -> Set<BuildInformation> {
        var info: Set<BuildInformation> = []

        // Do this first as it retries. The other checks below don't retry so will benefit from waiting if needed.
        let failures = try await searchForKnownBuildFailures()
        info.formUnion(failures)

        if try await hasTestResultFile() {
            info.insert(.hasTestResultsFile)
        }

        if try await hasLaunchResultFile() {
            info.insert(.hasLaunchResultsFile)
        }

        return info
    }

}

private extension LogInspector {

    func xcActivityLog() async throws -> String {
        let urls = try await filesCreatedAfterMinimumDate(in: buildDirectory, type: "xcactivitylog", retry: true)
        guard let url = urls.first else { throw "No logs found" }
        let data = try Data(contentsOf: url).gunzipped()
        guard let log = String(data: data, encoding: .utf8) else { throw "Failed to read log" }
        return log
    }

    func searchForKnownBuildFailures() async throws -> Set<BuildInformation> {
        let log = try await xcActivityLog()
        var failures: Set<BuildInformation> = []

        for failure in BuildInformation.allCases {
            // Search backwards as errors are usually at the end of the log
            guard let regex = failure.buildLogSearchRegex else { continue }
            if log.range(of: regex, options: [.backwards, .regularExpression]) != nil {
                failures.insert(failure)
            }
        }

        return failures
    }

    func hasTestResultFile() async throws -> Bool {
        try await filesCreatedAfterMinimumDate(in: testDirectory, type: "xcresult", retry: false).count > 0
    }

    func hasLaunchResultFile() async throws -> Bool {
        try await filesCreatedAfterMinimumDate(in: launchDirectory, type: "xcresult", retry: false).count > 0
    }

    func filesCreatedAfterMinimumDate(in directory: URL, type: String, retry: Bool) async throws -> [URL] {
        let result: [URL] = FileManager.default.filesCreatedAfter(date: minimumDate, in: directory, type: type)
        guard retry && result.isEmpty else { return result }

        // Wait for the file to be created if needed
        for _ in 0..<10 {
            let result = FileManager.default.filesCreatedAfter(date: minimumDate, in: directory, type: type)
            guard result.isEmpty else { return result }
            try await Task.sleep(for: .seconds(0.25))
        }

        return []
    }

}
