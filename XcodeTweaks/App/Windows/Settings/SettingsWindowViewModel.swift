//
//  SettingsWindowViewModel.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 25/7/2024.
//

import Foundation
import Combine
import AppKit

extension SettingsWindowView {
    
    final class ViewModel: ObservableObject {

        @Published var fixWhenRunningTests: Bool = true
        @Published var fixWhenLaunching: Bool = true
        @Published var allowRerunningIndividualTests: Bool = true
        @Published var allowKeyboardShortcuts: Bool = true
        @Published var allowCleaning: Bool = true
        @Published var allowResolvingPackages: Bool = true
        @Published var allowRestartXcode: Bool = false
        @Published var useWindowNames: Bool = true
        
        private var cancellables: Set<AnyCancellable> = []
        
        init() {
            setup()
        }
        
    }

}

extension SettingsWindowView.ViewModel {

    func resetOnboarding() {
        PersistedValues.shared.didTestSystemEventsAccess = false
        PersistedValues.shared.didSetUpBehaviours = false
        (NSApplication.shared.delegate as? AppDelegate)?.showMainWindow()
    }

}

private extension SettingsWindowView.ViewModel {

    func setup() {
        store($fixWhenRunningTests, \.fixWhenRunningTests, as: \.fixWhenRunningTests)
        store($fixWhenLaunching, \.fixWhenLaunching, as: \.fixWhenLaunching)
        store($allowRerunningIndividualTests, \.allowRerunningIndividualTests, as: \.allowRerunningIndividualTests)
        store($allowKeyboardShortcuts, \.allowKeyboardShortcuts, as: \.allowKeyboardShortcuts)
        store($allowCleaning, \.allowCleaning, as: \.allowCleaning)
        store($allowResolvingPackages, \.allowResolvingPackages, as: \.allowResolvingPackages)
        store($allowRestartXcode, \.allowRestartXcode, as: \.allowRestartXcode)
        store($useWindowNames, \.useWindowNames, as: \.useWindowNames)
    }

    func store<T>(_ value: Published<T>.Publisher, _ thisKeyPath: ReferenceWritableKeyPath<SettingsWindowView.ViewModel, T>, as keyPath: ReferenceWritableKeyPath<PersistedValues, T>) {
        self[keyPath: thisKeyPath] = PersistedValues.shared[keyPath: keyPath]
        value
            .assign(to: keyPath, on: PersistedValues.shared)
            .store(in: &cancellables)
    }

}
