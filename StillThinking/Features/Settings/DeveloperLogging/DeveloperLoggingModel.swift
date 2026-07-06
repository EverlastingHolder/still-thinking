//
//  DeveloperLoggingModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Observation

@MainActor
@Observable
final class DeveloperLoggingModel {
    var configuration: LogConfiguration

    private let store: DebugLogPreferencesStore

    init(store: DebugLogPreferencesStore) {
        self.store = store
        self.configuration = store.configuration
    }

    func setChannel(_ channel: LogChannel, isEnabled: Bool) {
        var channels = configuration.enabledChannels
        if isEnabled {
            channels.insert(channel)
        } else {
            channels.remove(channel)
        }
        configuration = LogConfiguration(enabledChannels: channels, minimumLevel: configuration.minimumLevel)
        store.configuration = configuration
    }

    func setMinimumLevel(_ level: LogLevel) {
        configuration = LogConfiguration(enabledChannels: configuration.enabledChannels, minimumLevel: level)
        store.configuration = configuration
    }

    func enableAll() {
        store.enableAll()
        configuration = store.configuration
    }

    func disableAll() {
        store.disableAll()
        configuration = store.configuration
    }

    func reset() {
        store.reset()
        configuration = store.configuration
    }
}
