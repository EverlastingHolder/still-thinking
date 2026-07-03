//
//  OSLogSink.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import OSLog

struct OSLogSink: LogSink {
    let subsystem: String

    func write(_ event: LogEvent) {
        let logger = Logger(subsystem: subsystem, category: event.channel.rawValue)
        let text = format(event)

        switch event.level {
        case .debug:
            logger.debug("\(text, privacy: .public)")
        case .info:
            logger.info("\(text, privacy: .public)")
        case .notice:
            logger.notice("\(text, privacy: .public)")
        case .error:
            logger.error("\(text, privacy: .public)")
        case .fault:
            logger.fault("\(text, privacy: .public)")
        }
    }

    private func format(_ event: LogEvent) -> String {
        guard !event.metadata.isEmpty else {
            return event.message
        }

        let metadata = event.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")

        return "\(event.message) \(metadata)"
    }
}
