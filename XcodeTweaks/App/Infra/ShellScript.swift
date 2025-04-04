//
//  ShellScript.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 4/4/2025.
//

import Foundation
import Cockle

final class ShellScript {

    private var shell: Shell?
    let name: String
    let executable: (Shell) throws -> Void

    init(name: String, executable: @escaping (Shell) throws -> Void) {
        self.name = name
        self.executable = executable
    }

    @discardableResult
    func execute() -> String? {
        do {
            if shell == nil {
                shell = try Shell(configuration: ShellConfiguration())
            }
            guard let shell else { return nil }
            try executable(shell)
            return nil
        } catch {
            print(error)
            return String(describing: error)
        }
    }

}

extension ShellScript {

    static func killXCBBuildService() -> ShellScript {
        ShellScript(
            name: "kill XCBBuildService",
            executable: { shell in
                try shell.killall(_v: (), _c: "XCBBuildService")
            }
        )
    }

}
