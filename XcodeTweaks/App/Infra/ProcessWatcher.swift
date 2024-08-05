//
//  ProcessWatcher.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 2/7/2024.
//

import Foundation
import Cockle

/// Suspends a task until a known Xcode process is completed.
final class ProcessWatcher {

    enum KnownProcess {
        case resolvePackages
        case clean

        var localisedName: String {
            switch self {
            case .resolvePackages: "Resolving Swift Packages"
            case .clean: "Cleaning"
            }
        }

        var processRegexes: [String] {
            switch self {
            case .resolvePackages: ["swift-frontend"] // swift-frontend.*-scan-dependencies
            case .clean: ["swift-frontend", "swift-driver"]
            }
        }
    }

    private lazy var shell = try! Shell(configuration: .init(xtrace: false))

    func waitForProcessMatchingRegexToEnd(_ knownProcess: KnownProcess) async throws {
        let startDate = Date()
        while Date().timeIntervalSince(startDate) < 10 {
            try await Task.sleep(for: .seconds(1))
            let processes = try getProcessList()
            let hasMatchingProcesses = processes
                .contains(
                    where: { processLine in
                        knownProcess.processRegexes.contains(
                            where: { processRegex in
                                processLine.range(of: processRegex, options: .regularExpression) != nil
                            }
                        )
                    }
                )
            if hasMatchingProcesses {
                continue
            } else {
                return
            }
        }

        throw "Timed out waiting for \(knownProcess.localisedName) to end."
    }

    private func getProcessList() throws -> [String] {
        let out = try shell.ps(_A: ())

        return out.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

}
