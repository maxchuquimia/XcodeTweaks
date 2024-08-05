//
//  Communication.swift
//  XcodeTweaks
//
//  Created by Max Chuquimia on 22/6/2024.
//

import Foundation
import Combine

/// Handles sending messages from Xcode Behaviour scripts to the fully running instance of XcodeTweaks.app
enum Communication {

    private static let notificationName = Notification.Name("com.chuquimianproductions.XcodeTweaks.Notify")
    private static let payloadKey = "m"

    static var notifications: AnyPublisher<XcodeTweaksNotification, Never> {
        DistributedNotificationCenter
            .default()
            .publisher(for: notificationName)
            .compactMap { info in info.userInfo?[payloadKey] as? Data }
            .compactMap { data in
                return try? JSONDecoder().decode(XcodeTweaksNotification.self, from: data)
            }
            .eraseToAnyPublisher()
    }

    static func post(notification: XcodeTweaksNotification) {
        guard let encodedNotification = try? JSONEncoder().encode(notification) else { return }
        DistributedNotificationCenter.default()
            .postNotificationName(
                notificationName,
                object: nil,
                userInfo: [payloadKey: encodedNotification],
                deliverImmediately: true
            )
    }

}
