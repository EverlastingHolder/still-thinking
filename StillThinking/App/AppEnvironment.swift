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
    let systemPromptObserver: SystemPromptObserver
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
        let systemPromptObserver = SystemPromptObserver()
        let scheduler = ReturnScheduler(
            repository: repository,
            notificationClient: LocalNotificationClient.live().observed(by: systemPromptObserver),
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
            authenticationClient: LocalAuthenticationClient.live().observed(by: systemPromptObserver),
            systemPromptObserver: systemPromptObserver,
            debugLogPreferencesStore: debugLogPreferencesStore,
            logConfigurationSource: logConfigurationSource
        )
    }
}

private extension AuthenticationClient {
    @MainActor
    func observed(by observer: SystemPromptObserver) -> AuthenticationClient {
        AuthenticationClient {
            availability()
        } authenticate: { reason in
            await observer.track {
                await authenticate(reason)
            }
        }
    }
}

private extension NotificationClient {
    @MainActor
    func observed(by observer: SystemPromptObserver) -> NotificationClient {
        NotificationClient {
            await authorizationStatus()
        } requestAuthorization: {
            try await observer.track {
                try await requestAuthorization()
            }
        } schedule: { request in
            try await schedule(request)
        } cancel: { identifiers in
            await cancel(identifiers)
        }
    }
}
