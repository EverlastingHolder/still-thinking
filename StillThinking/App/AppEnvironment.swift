//
//  AppEnvironment.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct AppEnvironment {
    let clock: ClockClient
    let uuidGenerator: UUIDGenerator
    let loggerFactory: LoggerFactory

    static func production(processInfo: ProcessInfo = .processInfo) -> AppEnvironment {
        let configuration = LogConfigurationParser.configuration(
            arguments: processInfo.arguments,
            environment: processInfo.environment,
            defaultConfiguration: .debugDefault
        )

        return AppEnvironment(
            clock: .live,
            uuidGenerator: .live,
            loggerFactory: LoggerFactory(
                configuration: configuration,
                sink: OSLogSink(subsystem: "com.everlastingholder.StillThinking")
            )
        )
    }
}
