//
//  NotificationClient+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

extension NotificationClient {
    static let denied = NotificationClient {
        .denied
    } requestAuthorization: {
        .denied
    } schedule: { _ in
    } cancel: { _ in
    }
}
