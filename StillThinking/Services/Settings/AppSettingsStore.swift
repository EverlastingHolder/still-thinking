//
//  AppSettingsStore.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppSettingsStore {
    private enum Key {
        static let showsThoughtTextInNotifications = "showsThoughtTextInNotifications"
        static let notificationStartHour = "notificationStartHour"
        static let notificationEndHour = "notificationEndHour"
        static let returnsPaused = "returnsPaused"
        static let privacyLockEnabled = "privacyLockEnabled"
    }

    var settings: AppSettings {
        didSet {
            save(settings)
        }
    }

    private let defaults: UserDefaults?

    init(settings: AppSettings = .default, defaults: UserDefaults? = nil) {
        self.defaults = defaults

        if let defaults {
            self.settings = Self.load(from: defaults)
        } else {
            self.settings = settings
        }
    }

    func reset() {
        settings = .default
    }

    private static func load(from defaults: UserDefaults) -> AppSettings {
        var settings = AppSettings.default
        settings.showsThoughtTextInNotifications = defaults.bool(forKey: Key.showsThoughtTextInNotifications)

        if defaults.object(forKey: Key.notificationStartHour) != nil {
            settings.notificationStartHour = defaults.integer(forKey: Key.notificationStartHour)
        }

        if defaults.object(forKey: Key.notificationEndHour) != nil {
            settings.notificationEndHour = defaults.integer(forKey: Key.notificationEndHour)
        }

        settings.returnsPaused = defaults.bool(forKey: Key.returnsPaused)
        settings.privacyLockEnabled = defaults.bool(forKey: Key.privacyLockEnabled)
        return settings.normalized
    }

    private func save(_ settings: AppSettings) {
        guard let defaults else {
            return
        }

        let normalizedSettings = settings.normalized
        defaults.set(normalizedSettings.showsThoughtTextInNotifications, forKey: Key.showsThoughtTextInNotifications)
        defaults.set(normalizedSettings.notificationStartHour, forKey: Key.notificationStartHour)
        defaults.set(normalizedSettings.notificationEndHour, forKey: Key.notificationEndHour)
        defaults.set(normalizedSettings.returnsPaused, forKey: Key.returnsPaused)
        defaults.set(normalizedSettings.privacyLockEnabled, forKey: Key.privacyLockEnabled)
    }
}

private extension AppSettings {
    var normalized: AppSettings {
        var settings = self
        settings.notificationStartHour = min(max(notificationStartHour, 0), 23)
        settings.notificationEndHour = min(max(notificationEndHour, settings.notificationStartHour + 1), 24)
        return settings
    }
}
