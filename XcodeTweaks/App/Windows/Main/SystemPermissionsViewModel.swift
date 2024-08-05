//
//  SystemPermissions.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 5/8/2024.
//

import Foundation
import Cocoa
import Combine
import Accessibility
import struct SwiftUI.Color

extension SystemPermissionsView {
    @MainActor
    final class ViewModel: ObservableObject {

        enum StepState {
            case none
            case pending
            case error
            case completed

            var color: Color {
                switch self {
                case .none: return .primary
                case .pending: return .yellow
                case .error: return .red
                case .completed: return .green
                }
            }
        }

        // tccutil reset All com.chuquimianproductions.XcodeTweaks
        @Published private(set) var isComplete: Bool = false
        @Published private(set) var error: String?
        @Published private(set) var accessibilityState: StepState = .none
        @Published private(set) var automationState: StepState = .none

        private var permissionsTask: Task<Void, Error>?
        private var cancellables: Set<AnyCancellable> = []

        init() {
            setup()
        }

    }
}

extension SystemPermissionsView.ViewModel {

    var isErrorAssistive: Bool {
        error?.contains("XcodeTweaks is not allowed assistive access") == true
    }

    func done() {
        PersistedValues.shared.didTestSystemEventsAccess = true
    }

    func requestPermissions() {
        permissionsTask?.cancel()
        permissionsTask = Task(priority: .userInitiated) {
            do {
                try await self.requestPermissions()
            } catch {
                guard !(error is CancellationError) && !Task.isCancelled else { return }
                self.error = error.localizedDescription + "\nTry again to continue."
                NSApp.requestUserAttention(.criticalRequest)
            }
        }
    }

}

private extension SystemPermissionsView.ViewModel {

    func setup() {
        PersistedValues.shared.$didTestSystemEventsAccess
            .filter { [weak self] in $0 != self?.isComplete }
            .assign(to: \.isComplete, on: self)
            .store(in: &cancellables)

        // When the user resets the setup, also reset the steps
        PersistedValues.shared.$didTestSystemEventsAccess
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.error = nil
                self?.accessibilityState = .none
                self?.automationState = .none
            }
            .store(in: &cancellables)

        if !AXIsProcessTrusted() {
            isComplete = false
        }
    }

    func requestPermissions() async throws {
        if NSRunningApplication.xcode == nil {
            throw "Please launch Xcode first."
        }

        if !AXIsProcessTrusted() {
            accessibilityState = .pending

            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options)

            // Wait for the user to enable access
            let timeout = Date().addingTimeInterval(30)
            while !AXIsProcessTrusted() {
                if Date() > timeout {
                    // Note this wording matches the native AppleScript error message
                    accessibilityState = .error
                    throw "XcodeTweaks is not allowed assistive access."
                }

                try await Task.sleep(for: .seconds(1))
            }
        }

        accessibilityState = .completed

        // Ideally we would now do something like
        //     let target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.dt.Xcode")
        //     AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true/false)
        // but it sometimes hangs forever and also doesn't support System Events.
        // So instead, literally just try to run an Apple Script that uses similar features to normal XcodeTweaks usage.

        automationState = .pending
        let error = AppleScript.testAllPermissions().execute()

        if let error = error {
            automationState = .error
            throw error
        }

        automationState = .completed
    }

}
