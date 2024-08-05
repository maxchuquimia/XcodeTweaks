//
//  SettingsWindowView.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 25/7/2024.
//

import Foundation
import SwiftUI

struct SettingsWindowView: View {

    @StateObject var viewModel: SettingsWindowView.ViewModel = SettingsWindowView.ViewModel()

    var body: some View {
        ScrollView {
            VStack  {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading) {
                        Text("Retry after known failures when…")
                            .font(.headline)
                        StandardToggle(isOn: .constant(true), label: "Building")
                            .disabled(true)

                        StandardToggle(isOn: $viewModel.fixWhenRunningTests, label: "Running Tests")
                        StandardToggle(isOn: $viewModel.fixWhenLaunching, label: "Launching")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text("Solve known failures by…")
                            .font(.headline)
                        StandardToggle(isOn: .constant(true), label: "Building")
                            .disabled(true)

                        StandardToggle(isOn: $viewModel.allowCleaning, label:"Cleaning")
                        StandardToggle(isOn: $viewModel.allowResolvingPackages, label: "Resolving Package Versions")
                        StandardToggle(
                            isOn: $viewModel.allowRestartXcode,
                            label: "Restarting Xcode",
                            help: "Feature coming soon?"
                        )
                        .disabled(true) // TODO: support this option
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text("Other")
                            .font(.headline)
                        StandardToggle(
                            isOn: $viewModel.allowKeyboardShortcuts,
                            label: "Prefer keyboard shortcuts",
                            help: "When possible, send keyboard shortcuts to Xcode instead of clicking named menu items."
                        )
                        StandardToggle(
                            isOn: $viewModel.useWindowNames,
                            label: "Use window names",
                            help: "Before retrying, switch to the window that matches the project name. May not work in some cases."
                        )
                        StandardToggle(
                            isOn: $viewModel.allowRerunningIndividualTests,
                            label: "Use ⌃⌥⌘+G to run tests",
                            help: "This will re-run the last test or suite you ran rather than all tests in the project. May not work for all projects."
                        )

                        Button("Reset Permissions & Setup Onboarding") {
                            viewModel.resetOnboarding()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
                    .frame(height: 20)

                HStack {
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))")

                    Text("[Check for updates on GitHub](https://github.com/maxchuquimia/XcodeTweaks)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 450, minHeight: 450)
    }

}
