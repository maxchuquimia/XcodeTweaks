//
//  AppleScript.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation
import AppKit
import SwiftAppleScript

final class AppleScript {

    private let underlyingScript: NSAppleScript?
    let name: String

    init(name: String, @SwiftAppleScript.AppleScript script: () -> ScriptPart) {
        self.name = name
        let source = script().script
        print(source)
        underlyingScript = NSAppleScript(source: source)
        underlyingScript?.compileAndReturnError(nil)
    }

    @discardableResult
    func execute() -> String? {
        var error: NSDictionary?
        underlyingScript?.executeAndReturnError(&error)

        if let error = error {
            print(error)
            return (error.value(forKey: "NSAppleScriptErrorMessage") as? String) ?? String(describing: error)
        }

        return nil
    }

}

extension AppleScript {

    static func build(projectName: String?, useShortcuts: Bool) -> AppleScript {
        AppleScript(
            name: "build",
            script: {
                Tell(application: "Xcode") {
                    Activate()

                    if let projectName {
                        SwiftAppleScript.Set("index", of: "first window whose name contains \"\(projectName)\"", to: "1")
                    }

                    Tell(application: "System Events") {
                        if useShortcuts {
                            Keystroke("b", using: .command)
                        } else {
                            Tell(applicationProcess: "Xcode") {
                                Tell(menuBar: 1) {
                                    Tell(menuBarItem: "Product") {
                                        Tell(menu: "Product") {
                                            Click(menuItem: "Build")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        )
    }

    static func runTests(projectName: String?, useRerunShortcut: Bool, useShortcuts: Bool) -> AppleScript {
        AppleScript(
            name: "test again",
            script: {
                Tell(application: "Xcode") {
                    Activate()

                    if let projectName {
                        SwiftAppleScript.Set("index", of: "first window whose name contains \"\(projectName)\"", to: 1)
                    }

                    Tell(application: "System Events") {
                        if useRerunShortcut {
                            Keystroke("g", using: .command, .option, .control)
                        } else if useShortcuts {
                            Keystroke("u", using: .command)
                        } else {
                            Tell(applicationProcess: "Xcode") {
                                Tell(menuBar: 1) {
                                    Tell(menuBarItem: "Product") {
                                        Tell(menu: "Product") {
                                            Click(menuItem: "Test")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
    }
    static func launchApp(projectName: String?, useShortcuts: Bool) -> AppleScript {
        AppleScript(
            name: "launch",
            script: {
                Tell(application: "Xcode") {
                    Activate()

                    if let projectName {
                        SwiftAppleScript.Set("index", of: "first window whose name contains \"\(projectName)\"", to: 1)
                    }

                    Tell(application: "System Events") {
                        if useShortcuts {
                            Keystroke("r", using: .command)
                        } else {
                            Tell(applicationProcess: "Xcode") {
                                Tell(menuBar: 1) {
                                    Tell(menuBarItem: "Product") {
                                        Tell(menu: "Product") {
                                            Click(menuItem: "Run")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        )
    }

    static func clean(projectName: String?, useShortcuts: Bool) -> AppleScript {
        AppleScript(
            name: "clean",
            script: {
                Tell(application: "Xcode") {
                    Activate()

                    if let projectName {
                        SwiftAppleScript.Set("index", of: "first window whose name contains \"\(projectName)\"", to: 1)
                    }
                    
                    Tell(application: "System Events") {
                        if useShortcuts {
                            Keystroke("k", using: .command, .shift)
                        } else {
                            Tell(applicationProcess: "Xcode") {
                                Tell(menuBar: 1) {
                                    Tell(menuBarItem: "Product") {
                                        Tell(menu: "Product") {
                                            Click(menuItem: "Clean Build Folder…")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        )
    }

    static func resolvePackageVersions(projectName: String?) -> AppleScript {
        AppleScript(
            name: "resolve package versions",
            script: {
                Tell(application: "Xcode") {
                    Activate()

                    if let projectName {
                        SwiftAppleScript.Set("index", of: "first window whose name contains \"\(projectName)\"", to: 1)
                    }

                    Tell(application: "System Events") {
                        Tell(applicationProcess: "Xcode") {
                            Tell(menuBar: 1) {
                                Tell(menuBarItem: "File") {
                                    Tell(menu: "File") {
                                        Tell(menuItem: "Packages") {
                                            Tell(menu: "Packages") {
                                                Click(menuItem: "Resolve Package Versions")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        )
    }

    static func displayDialog(message: String) -> AppleScript {
        AppleScript(
            name: "display dialog",
            script: {
                Tell(application: "System Events") {
                    Display(dialog: message)
                }
            }
        )
    }

    static func testAllPermissions() -> AppleScript {
        AppleScript(
            name: "test all permissions",
            script: {
//                Tell(application: "System Events") {
//                    Display(dialog: "Before continuing, ensure Xcode is running.\n\nPressing OK will open and close Xcode's About and Preferences windows.\n\nThis will result in two Xcode-specific Automation permission prompts. Automation access is required to send keyboard shortcuts to Xcode.")
//
//                    Delay(0.5)
//                }

                Tell(application: "Xcode") {
                    Activate()
                }

                Delay(0.5)


                Tell(application: "System Events") {
                    Tell(applicationProcess: "Xcode") {
                        Activate()

                        Tell(menuBar: 1) {
                            Tell(menuBarItem: "Xcode") {
                                Tell(menu: "Xcode") {
                                    Click(menuItem: "About Xcode")
                                }
                            }
                        }
                    }
                }

                Delay(0.5)

                Tell(application: "Xcode") {
                    Activate()
                    SwiftAppleScript.Set("index", of: "first window", to: 1)
                }

                Tell(application: "System Events") {
                    Tell(applicationProcess: "Xcode") {
                        Keystroke("w", using: .command)
                    }
                }

                Delay(0.5)

                Tell(application: "XcodeTweaks") {
                    Activate()
                }
            }
        )
    }

}
