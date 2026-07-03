//
//  LogEvent.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

struct LogEvent: Sendable, Equatable {
    let channel: LogChannel
    let level: LogLevel
    let message: String
    let metadata: [String: String]
}
