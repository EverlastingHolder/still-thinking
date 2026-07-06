//
//  AppEnvironment.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

struct AppEnvironment {
    let clock: ClockClient
    let uuidGenerator: UUIDGenerator
    let loggerFactory: LoggerFactory
    let thoughtRepository: any ThoughtRepository
    let returnScheduler: ReturnScheduler
    let settingsStore: AppSettingsStore
    let authenticationClient: AuthenticationClient
    let debugLogPreferencesStore: DebugLogPreferencesStore
    let logConfigurationSource: LogConfigurationSource

    @MainActor
    static func production(processInfo: ProcessInfo = .processInfo) throws -> AppEnvironment {
        #if DEBUG
        let debugLogPreferencesStore = DebugLogPreferencesStore(defaults: .standard)
        let defaultLogConfiguration = LogConfiguration.debugDefault
        let debugPreferences = debugLogPreferencesStore.hasSavedConfiguration
            ? debugLogPreferencesStore.configuration
            : nil
        #else
        let debugLogPreferencesStore = DebugLogPreferencesStore(configuration: .releaseDefault)
        let defaultLogConfiguration = LogConfiguration.releaseDefault
        let debugPreferences: LogConfiguration? = nil
        #endif

        let configuration = LogConfigurationParser.configuration(
            arguments: processInfo.arguments,
            environment: processInfo.environment,
            defaultConfiguration: defaultLogConfiguration,
            debugPreferences: debugPreferences
        )
        let logConfigurationSource = LogConfigurationParser.source(
            arguments: processInfo.arguments,
            environment: processInfo.environment,
            debugPreferences: debugPreferences
        )
        let loggerFactory = LoggerFactory(
            configuration: configuration,
            sink: OSLogSink(subsystem: "com.everlastingholder.StillThinking")
        )
        let container = try StillThinkingModelContainerFactory.production()
        let repository = SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
        let settingsStore = AppSettingsStore(defaults: .standard)
        let scheduler = ReturnScheduler(
            repository: repository,
            notificationClient: LocalNotificationClient.live(),
            settingsStore: settingsStore,
            clock: .live,
            logger: loggerFactory.makeLogger(for: .scheduling)
        )

        return AppEnvironment(
            clock: .live,
            uuidGenerator: .live,
            loggerFactory: loggerFactory,
            thoughtRepository: repository,
            returnScheduler: scheduler,
            settingsStore: settingsStore,
            authenticationClient: LocalAuthenticationClient.live(),
            debugLogPreferencesStore: debugLogPreferencesStore,
            logConfigurationSource: logConfigurationSource
        )
    }
}
