//
//  MainWindowView.ViewModel.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation
import AppKit
import Combine
import XCLogParser

extension MainWindowView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var consoleLines: [ConsoleLine] = []
        @Published var automaticallyResolvedFailures: Int = 0

        private var cancellables: Set<AnyCancellable> = []
        private var projects: [XcodeProjectState.Location: XcodeProjectState] = [:]
        private let processWatcher = ProcessWatcher()

        init() {
            setup()
        }

    }

}

extension MainWindowView.ViewModel {

    func onClickOpenPreferences() {
        NSApp.sendAction(#selector(AppDelegate.showSettings(sender:)), to: nil, from: nil)
    }

}

private extension MainWindowView.ViewModel {

    func setup() {
        Communication.notifications
            .sink { [weak self] notification in
                guard let self else { return }
                Task(priority: .userInitiated) {
                    await self.handle(notification: notification)
                }
            }
            .store(in: &cancellables)

        PersistedValues.shared.$automaticallyResolvedFailures
            .assign(to: \.automaticallyResolvedFailures, on: self)
            .store(in: &cancellables)

        appendConsole("Listening for notifications", .dim)
        // loadConsoleForMarketingScreenshots()
    }

    func handle(notification: XcodeTweaksNotification) async {
        let environment = notification.environment
        print("Received \(notification.alertMessage.rawValue) : \(notification.environment)")

        do {
            switch notification.alertMessage {
            case .buildStarted:
                appendConsole(environment,"Build started", .dim)
                getProject(for: environment).lastBuildSuccessDate = Date()
            case .buildSucceeded:
                appendConsole(environment,"Build succeeded", .dim)
                getProject(for: environment).numberOfRetriesRemaining = XcodeProjectState.maxRetries
            case .buildFailed:
                appendConsole(environment,"Build failed", .dim)
                try await handleFailure(environment: notification.environment)
            case .testStarted:
                appendConsole(environment,"Test started", .dim)
            case .testSucceeded:
                appendConsole(environment,"Test succeeded", .dim)
            case .testFailed:
                appendConsole(environment, "Test failed", .dim)
            }
        } catch {
            appendConsole(environment, "Error: \(error)", .error)
        }
    }

    func handleFailure(environment: XcodeTweaksNotification.Environment) async throws {
        do {
            let inspector = try LogInspector(environment: environment, minimumDate: getProject(for: environment).lastBuildSuccessDate)
            let buildInfo = try await inspector.buildInformation()

            if buildInfo.contains(.hasTestResultsFile) && !PersistedValues.shared.fixWhenRunningTests {
                return appendConsole(environment, "Fixing failures when running tests is disabled", .dim)
            }

            if buildInfo.contains(.hasLaunchResultsFile) && !PersistedValues.shared.fixWhenLaunching {
                return appendConsole(environment, "Fixing failures when launching is disabled", .dim)
            }

            // What was the user was trying to do when the build failed?
            let attemptedAction: AppleScript = if buildInfo.contains(.hasTestResultsFile) {
                .runTests(
                    projectName: environment.projectNameWithoutExtension,
                    useRerunShortcut: PersistedValues.shared.allowRerunningIndividualTests,
                    useShortcuts: PersistedValues.shared.allowKeyboardShortcuts
                )
            } else if buildInfo.contains(.hasLaunchResultsFile) {
                .launchApp(
                    projectName: environment.projectNameWithoutExtension,
                    useShortcuts: PersistedValues.shared.allowKeyboardShortcuts
                )
            } else {
                .build(
                    projectName: environment.projectNameWithoutExtension,
                    useShortcuts: PersistedValues.shared.allowKeyboardShortcuts
                )
            }

            if buildInfo.contains(.canBuildAgainToContinue) {
                // Just do the same thing again
                appendBuildInfoCelebrationIfNeeded(buildInfo, for: environment)
                try perform(attemptedAction, for: environment)
                incrementResolutionCounter()
            } else if buildInfo.contains(.containsMultipleReferencesWithSameGUID) {
                // Resolve packages then build
                appendBuildInfoCelebrationIfNeeded(buildInfo, for: environment)
                try await resolvePackageVersions(for: environment)
                try perform(attemptedAction, for: environment)
                incrementResolutionCounter()
            } else if buildInfo.contains(.receivedMultipleTargetEndedMessagesForTargetID) || buildInfo.contains(.targetIDNotFoundInActiveTargets) || buildInfo.contains(.codesignFailedWithNonZeroExitCode) {
                // Clean then build
                appendBuildInfoCelebrationIfNeeded(buildInfo, for: environment)
                try await cleanDerivedData(for: environment)
                try perform(attemptedAction, for: environment)
                incrementResolutionCounter()
            } else {
                appendConsole(environment, "No known recovery steps for build failure", .dim)
            }
        } catch let error as PreferencesError {
            appendConsole(environment, error.localizedDescription, .dim)
        } catch {
            appendConsole(environment, "Error: \(error)", .error)
        }
    }

    func perform(_ script: AppleScript, for environment: XcodeTweaksNotification.Environment) throws {
        guard getProject(for: environment).numberOfRetriesRemaining > 0 else {
            throw "Not running \"\(script.name)\" due multiple consecutive failures"
        }

        getProject(for: environment).numberOfRetriesRemaining -= 1

        appendConsole(environment, "Running \"\(script.name)\"", .normal)
        let error = script.execute()
        
        if let error {
            throw error
        }
    }

    func appendConsole(_ environment: XcodeTweaksNotification.Environment, _ message: String, _ style: ConsoleLine.Style) {
        appendConsole("\(environment.projectName ?? "Unknown project") - \(message)", style)
    }

    func appendBuildInfoCelebrationIfNeeded(_ buildInfo: Set<LogInspector.BuildInformation>, for environment: XcodeTweaksNotification.Environment) {
        for info in buildInfo {
            if let name = info.localizedName {
                appendConsole(environment, "Found resolvable error \"\(name)\"", .normal)
                return // Just printing one is fine
            }
        }
    }

    func appendConsole(_ message: String, _ style: ConsoleLine.Style) {
        var lines = consoleLines
        lines.append(ConsoleLine(date: Date(), message: message, style: style))
        
        if lines.count > 50 {
            lines.removeFirst()
        }

        consoleLines = lines
    }

    func resolvePackageVersions(for environment: XcodeTweaksNotification.Environment) async throws {
        guard PersistedValues.shared.allowResolvingPackages else {
            throw PreferencesError.resolvingPackagesDisabled
        }
        try perform(.resolvePackageVersions(projectName: environment.projectNameWithoutExtension), for: environment)
        try await processWatcher.waitForProcessMatchingRegexToEnd(.resolvePackages)
    }

    func cleanDerivedData(for environment: XcodeTweaksNotification.Environment) async throws {
        // Clean then build
        guard PersistedValues.shared.allowCleaning else {
            throw PreferencesError.cleaningDisabled
        }
        try perform(.clean(projectName: environment.projectNameWithoutExtension, useShortcuts: PersistedValues.shared.allowKeyboardShortcuts), for: environment)
        try await processWatcher.waitForProcessMatchingRegexToEnd(.clean)
    }

    func getProject(for environment: XcodeTweaksNotification.Environment) -> XcodeProjectState {
        if let project = projects[environment.projectLocation] {
            return project
        } else {
            let project = XcodeProjectState(location: environment.projectLocation)
            projects[environment.projectLocation] = project
            return project
        }
    }

    func incrementResolutionCounter() {
        PersistedValues.shared.automaticallyResolvedFailures += 1
    }

    #if DEBUG
    func loadConsoleForMarketingScreenshots() {
        let fakeEnvironment = XcodeTweaksNotification.Environment(
            projectName: "MyApp.xcodeproj",
            projectPath: nil,
            workspacePath: nil,
            xcodeDeveloperDirectory: nil
        )

        appendConsole(fakeEnvironment, "Build started", .dim)
        appendConsole(fakeEnvironment, "Build succeeded", .dim)
        appendConsole(fakeEnvironment, "Build started", .dim)
        appendConsole(fakeEnvironment, "Build succeeded", .dim)
        appendConsole(fakeEnvironment, "Build started", .dim)
        appendConsole(fakeEnvironment, "Build failed", .dim)
        appendBuildInfoCelebrationIfNeeded([.canBuildAgainToContinue], for: fakeEnvironment)
        appendConsole(fakeEnvironment, "Running \"\(AppleScript.build(projectName: nil, useShortcuts: true).name)\"", .normal)
        appendConsole(fakeEnvironment, "Build started", .dim)
        appendConsole(fakeEnvironment, "Build succeeded", .dim)
        appendConsole(fakeEnvironment, "Build started", .dim)
        appendConsole(fakeEnvironment, "Build failed", .dim)
        appendBuildInfoCelebrationIfNeeded([.containsMultipleReferencesWithSameGUID], for: fakeEnvironment)
        appendConsole(fakeEnvironment, "Running \"\(AppleScript.resolvePackageVersions(projectName: nil).name)\"", .normal)
        appendConsole(fakeEnvironment, "Running \"\(AppleScript.runTests(projectName: nil, useRerunShortcut: true, useShortcuts: true).name)\"", .normal)
        appendConsole(fakeEnvironment, "Build started", .dim)
        appendConsole(fakeEnvironment, "Build succeeded", .dim)

        automaticallyResolvedFailures = 84
    }
    #endif

}

private enum PreferencesError: LocalizedError {
    case resolvingPackagesDisabled
    case cleaningDisabled

    var errorDescription: String? {
        switch self {
        case .resolvingPackagesDisabled:
            return "Resolving packages to fix failures is disabled"
        case .cleaningDisabled:
            return "Cleaning to fix failures is disabled"
        }
    }
}
