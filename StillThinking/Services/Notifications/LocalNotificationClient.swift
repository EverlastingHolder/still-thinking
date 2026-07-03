//
//  LocalNotificationClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import UserNotifications

enum LocalNotificationClient {
    static func live(center: UNUserNotificationCenter = .current()) -> NotificationClient {
        NotificationClient {
            await center.notificationSettings().authorizationStatus.domainStatus
        } requestAuthorization: {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted ? .authorized : .denied
        } schedule: { request in
            let content = UNMutableNotificationContent()
            content.title = request.title
            content.body = request.body

            let interval = max(request.dueAt.timeIntervalSinceNow, 1)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let notificationRequest = UNNotificationRequest(
                identifier: request.identifier,
                content: content,
                trigger: trigger
            )

            try await center.add(notificationRequest)
        } cancel: { identifiers in
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}

private extension UNAuthorizationStatus {
    var domainStatus: NotificationAuthorizationStatus {
        switch self {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .authorized:
            .authorized
        case .provisional:
            .provisional
        case .ephemeral:
            .ephemeral
        @unknown default:
            .unknown
        }
    }
}
