//
//  DeveloperLoggingTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import Testing
@testable import StillThinking

@MainActor
@Suite("Developer logging")
struct DeveloperLoggingTests {
    @Test("Toggles обновляют configuration store")
    func togglesUpdateConfigurationStore() {
        let store = DebugLogPreferencesStore()
        let model = DeveloperLoggingModel(store: store)

        model.setChannel(.database, isEnabled: true)
        model.setMinimumLevel(.debug)

        #expect(store.configuration.enabledChannels.contains(.database))
        #expect(store.configuration.minimumLevel == .debug)
    }

    @Test("Сохранённые toggles используются после environment и launch arguments")
    func savedTogglesHaveLowerPriorityThanEnvironmentAndArguments() {
        let debugPreferences = LogConfiguration(enabledChannels: [.database], minimumLevel: .debug)
        let configuration = LogConfigurationParser.configuration(
            arguments: ["app", "-STLogChannels", "app"],
            environment: ["ST_LOG_CHANNELS": "notifications"],
            defaultConfiguration: .debugDefault,
            debugPreferences: debugPreferences
        )
        let source = LogConfigurationParser.source(
            arguments: ["app", "-STLogChannels", "app"],
            environment: ["ST_LOG_CHANNELS": "notifications"],
            debugPreferences: debugPreferences
        )

        #expect(configuration.enabledChannels == [.app])
        #expect(source == .launchArguments)
    }

    @Test("Release default не разрешает debug/info")
    func releaseDefaultDoesNotAllowDebugAndInfo() {
        #expect(LogConfiguration.releaseDefault.allows(channel: .app, level: .debug) == false)
        #expect(LogConfiguration.releaseDefault.allows(channel: .app, level: .info) == false)
        #expect(LogConfiguration.releaseDefault.allows(channel: .app, level: .error))
    }
}
