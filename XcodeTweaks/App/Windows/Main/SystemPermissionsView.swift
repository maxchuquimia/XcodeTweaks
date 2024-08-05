//
//  SystemPermissionsView.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 5/8/2024.
//

import SwiftUI

struct SystemPermissionsView: View {
   
    @EnvironmentObject var viewModel: SystemPermissionsView.ViewModel

    var isComplete: Bool {
        viewModel.automationState == .completed && viewModel.accessibilityState == .completed
    }

    var body: some View {
        HStack {
            VStack(spacing: 16) {
                Text("Grant Permissions")
                    .font(.title)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Before you can use _XcodeTweaks_, you need to grant the following permissions in **System Preferences > Security & Privacy**")

                    Text("**• Accessibility** (add _XcodeTweaks_ to the list and turn on)")
                        .foregroundColor(viewModel.accessibilityState.color)

                    Text("**• Automation** (under _XcodeTweaks_ turn on _Xcode_ & _System Events_)")
                        .foregroundColor(viewModel.automationState.color)

                    Text("This will be done through 3 system alerts and involves automatically opening & closing Xcode's _About_ window using AppleScript.")

                    Spacer()
                        .frame(width: 6, height: 6)

                    if let error = viewModel.error, !isComplete {
                        Text(error)
                            .foregroundColor(.red)
                    } else if isComplete {
                        Text("Done! When you update Xcode you can repeat these steps from XcodeTweak's Preferences.")
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                if isComplete {
                    Button("Continue") {
                        viewModel.done()
                    }
                } else {
                    if viewModel.error != nil {
                        Button("Try again") {
                            viewModel.requestPermissions()
                        }
                    } else {
                        Button("Grant Permissions") {
                            viewModel.requestPermissions()
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()

            Spacer(minLength: 0)

            Image(.privacy)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

}
