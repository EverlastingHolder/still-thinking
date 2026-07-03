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

    @MainActor
    static func production(processInfo: ProcessInfo = .processInfo) throws -> AppEnvironment {
        let configuration = LogConfigurationParser.configuration(
            arguments: processInfo.arguments,
            environment: processInfo.environment,
            defaultConfiguration: .debugDefault
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

        return AppEnvironment(
            clock: .live,
            uuidGenerator: .live,
            loggerFactory: loggerFactory,
            thoughtRepository: repository
        )
    }
}
