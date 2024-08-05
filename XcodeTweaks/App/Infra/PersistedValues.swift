//
//  PersistedValues.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 1/8/2024.
//

import Foundation
import Combine

final class PersistedValues {

    static let shared = PersistedValues()

    @SingletonUserDefault("fixWhenRunningTests", defaultValue: true)
    var fixWhenRunningTests: Bool

    @SingletonUserDefault("fixWhenLaunching", defaultValue: true)
    var fixWhenLaunching: Bool

    @SingletonUserDefault("allowRerunningIndividualTests", defaultValue: true)
    var allowRerunningIndividualTests: Bool

    @SingletonUserDefault("allowKeyboardShortcuts", defaultValue: true)
    var allowKeyboardShortcuts: Bool

    @SingletonUserDefault("allowCleaning", defaultValue: true)
    var allowCleaning: Bool

    @SingletonUserDefault("allowResolvingPackages", defaultValue: true)
    var allowResolvingPackages: Bool

    @SingletonUserDefault("allowRestartXcode", defaultValue: false)
    var allowRestartXcode: Bool

    @SingletonUserDefault("useWindowNames", defaultValue: true)
    var useWindowNames: Bool

    @SingletonUserDefault("didTestSystemEventsAccess", defaultValue: false)
    var didTestSystemEventsAccess: Bool

    @SingletonUserDefault("didSetUpBehaviours", defaultValue: false)
    var didSetUpBehaviours: Bool

    @SingletonUserDefault("automaticallyResolvedFailures", defaultValue: 0)
    var automaticallyResolvedFailures: Int

    private init() { }

}

// Change publishing only works if attached to a singleton's property
@propertyWrapper
struct SingletonUserDefault<Value> {

    fileprivate let key: String
    fileprivate let defaultValue: Value
    fileprivate let publisher: CurrentValueSubject<Value, Never>

    fileprivate init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.publisher = CurrentValueSubject(UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue)
    }

    var wrappedValue: Value {
        get { 
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        publisher.eraseToAnyPublisher()
    }

}
