//
//  MainWindowView.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import SwiftUI

struct MainWindowView: View {

    @StateObject var viewModel = MainWindowView.ViewModel()
    @StateObject var systemViewModel = SystemPermissionsView.ViewModel()
    @StateObject var setupViewModel = SetupInstructionsView.ViewModel()

    var failureCount: Int { 
        viewModel.automaticallyResolvedFailures
    }

    var body: some View {
        VStack {
            if !systemViewModel.isComplete {
                SystemPermissionsView()
                    .environmentObject(systemViewModel)
            } else if !setupViewModel.isComplete {
                SetupInstructionsView()
                    .environmentObject(setupViewModel)
            } else {
                mainContent
            }
        }
        .frame(minWidth: 650, minHeight: 400, maxHeight: 600)
    }

    var mainContent: some View {
        VStack {
            HStack {
                Text("XcodeTweaks has responded to **\(failureCount)** failure\(failureCount == 1 ? "" : "s") for you \(failureCount > 0 ? "🎉" : "")")
                Spacer()

                Button("Settings") {
                    viewModel.onClickOpenPreferences()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
                .frame(height: 10)

            ConsoleView(lines: viewModel.consoleLines)
                .frame(minHeight: 50)
        }
        .padding()
    }

}
