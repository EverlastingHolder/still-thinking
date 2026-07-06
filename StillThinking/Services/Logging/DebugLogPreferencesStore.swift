//
//  DebugLogPreferencesStore.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class DebugLogPreferencesStore {
    private enum Key {
        static let channels = "debugLogChannels"
        static let minimumLevel = "debugLogMinimumLevel"
    }

    var configuration: LogConfiguration {
        didSet {
            save(configuration)
        }
    }

    private(set) var hasSavedConfiguration: Bool
    private let defaults: UserDefaults?

    init(configuration: LogConfiguration = .debugDefault, defaults: UserDefaults? = nil) {
        self.defaults = defaults

        if let defaults {
            let loadedConfiguration = Self.load(from: defaults)
            self.configuration = loadedConfiguration ?? configuration
            self.hasSavedConfiguration = loadedConfiguration != nil
        } else {
            self.configuration = configuration
            self.hasSavedConfiguration = false
        }
    }

    func enableAll() {
        configuration = LogConfiguration(
            enabledChannels: Set(LogChannel.allCases),
            minimumLevel: configuration.minimumLevel
        )
    }

    func disableAll() {
        configuration = LogConfiguration(enabledChannels: [], minimumLevel: configuration.minimumLevel)
    }

    func reset() {
        configuration = .debugDefault
    }

    private static func load(from defaults: UserDefaults) -> LogConfiguration? {
        guard let rawChannels = defaults.stringArray(forKey: Key.channels),
              let rawLevel = defaults.string(forKey: Key.minimumLevel),
              let level = LogLevel(rawValue: rawLevel) else {
            return nil
        }

        return LogConfiguration(
            enabledChannels: Set(rawChannels.compactMap(LogChannel.init(rawValue:))),
            minimumLevel: level
        )
    }

    private func save(_ configuration: LogConfiguration) {
        defaults?.set(configuration.enabledChannels.map(\.rawValue).sorted(), forKey: Key.channels)
        defaults?.set(configuration.minimumLevel.rawValue, forKey: Key.minimumLevel)
        hasSavedConfiguration = true
    }
}
