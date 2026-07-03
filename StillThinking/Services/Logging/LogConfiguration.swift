//
//  LogConfiguration.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

struct LogConfiguration: Sendable, Equatable {
    let enabledChannels: Set<LogChannel>
    let minimumLevel: LogLevel

    static let debugDefault = LogConfiguration(
        enabledChannels: [.app],
        minimumLevel: .info
    )

    static let releaseDefault = LogConfiguration(
        enabledChannels: Set(LogChannel.allCases),
        minimumLevel: .error
    )

    static let disabled = LogConfiguration(
        enabledChannels: [],
        minimumLevel: .fault
    )

    func allows(channel: LogChannel, level: LogLevel) -> Bool {
        enabledChannels.contains(channel) && level >= minimumLevel
    }
}
