//
//  StandardToggle.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 8/8/2024.
//

import Foundation
import SwiftUI

struct StandardToggle: View {

    var isOn: Binding<Bool>
    var label: String
    var help: String? = nil

    @State private var isHelpVisible = false

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(
                isOn: isOn,
                label: {
                    Text(label)
                        .monospacedDigit()
                }
            )
            .fixedSize()

            if let help {
                Text(help)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 2)
    }
}
