//
//  SetupInstructionsView.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 7/8/2024.
//

import SwiftUI

struct SetupInstructionsView: View {

    @EnvironmentObject var viewModel: SetupInstructionsView.ViewModel

    var isAllTogglesChecked: Bool {
        viewModel.toggleBuildStarts &&
            viewModel.toggleBuildSucceeds &&
            viewModel.toggleBuildFails
    }

    var body: some View {
        HStack {
            VStack(spacing: 16) {
                Text("Add Xcode Behaviours")
                    .font(.title)

                Text("_XcodeTweaks_ has a simple shell script that needs to be run from various **Xcode > Settings > Behaviours**.")
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Text("Save the script: ")
                    Button("Choose location...") {
                        viewModel.saveScript()
                    }
                    Text(viewModel.savedPath)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.secondary)
                        .layoutPriority(-1)
                        .help(viewModel.savedPath)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Use the checklist to ensure you have added the correct Behaviours manually in Xcode.")

                    StandardToggle(isOn: $viewModel.toggleBuildStarts, label: "1. Build > Starts > Run")
                    StandardToggle(isOn: $viewModel.toggleBuildSucceeds, label: "2. Build > Succeeds > Run")
                    StandardToggle(isOn: $viewModel.toggleBuildFails, label: "3. Build > Fails > Run")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button("Checklist Complete") {
                    viewModel.done()
                }
                .disabled(!isAllTogglesChecked)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()

            Spacer(minLength: 0)

            Image(.behaviours)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

}
