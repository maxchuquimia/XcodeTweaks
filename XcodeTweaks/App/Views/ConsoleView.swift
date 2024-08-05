//
//  ConsoleView.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 28/6/2024.
//

import SwiftUI

struct ConsoleLine: Equatable {
    enum Style {
        case normal
        case error
        case dim

        var color: Color {
            switch self {
            case .normal: return .white
            case .error: return .red
            case .dim: return .gray
            }
        }
    }

    let date: Date
    let message: String
    let style: Style
}

struct ConsoleView: View {

    let lines: [ConsoleLine]

    var body: some View {
        ZStack {
            Color.black

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(lines, id: \.date) { line in
                            Text("[\(line.date.formatted(date: .numeric, time: .standard))] \(line.message)")
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .font(.body.monospaced())
                                .foregroundColor(line.style.color)
                                .padding(.horizontal, 10)
                                .id(line.date)
                                .textSelection(.enabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: lines) { new in
                    withAnimation {
                        proxy.scrollTo(new.last?.date, anchor: .bottom)
                    }
                }
            }
        }
    }

}
