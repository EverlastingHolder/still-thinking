//
//  AppSettings.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation

struct AppSettings: Equatable, Sendable {
    var showsThoughtTextInNotifications: Bool
    var notificationStartHour: Int
    var notificationEndHour: Int
    var returnsPaused: Bool
    var privacyLockEnabled: Bool

    static let `default` = AppSettings(
        showsThoughtTextInNotifications: false,
        notificationStartHour: 9,
        notificationEndHour: 21,
        returnsPaused: false,
        privacyLockEnabled: false
    )

    func notificationDate(for dueAt: Date, calendar: Calendar) -> Date {
        let hour = calendar.component(.hour, from: dueAt)

        if hour < notificationStartHour {
            return calendar.date(bySettingHour: notificationStartHour, minute: 0, second: 0, of: dueAt) ?? dueAt
        }

        if hour >= notificationEndHour {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: dueAt) ?? dueAt
            return calendar.date(bySettingHour: notificationStartHour, minute: 0, second: 0, of: nextDay) ?? dueAt
        }

        return dueAt
    }
}
