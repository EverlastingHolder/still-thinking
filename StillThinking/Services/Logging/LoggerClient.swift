//
//  LoggerClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

struct LoggerClient {
    private let channel: LogChannel
    private let configuration: LogConfiguration
    private let sink: any LogSink

    init(channel: LogChannel, configuration: LogConfiguration, sink: any LogSink) {
        self.channel = channel
        self.configuration = configuration
        self.sink = sink
    }

    func debug(_ message: @autoclosure () -> String, metadata: @autoclosure () -> [String: String] = [:]) {
        log(.debug, message: message, metadata: metadata)
    }

    func info(_ message: @autoclosure () -> String, metadata: @autoclosure () -> [String: String] = [:]) {
        log(.info, message: message, metadata: metadata)
    }

    func notice(_ message: @autoclosure () -> String, metadata: @autoclosure () -> [String: String] = [:]) {
        log(.notice, message: message, metadata: metadata)
    }

    func error(_ message: @autoclosure () -> String, metadata: @autoclosure () -> [String: String] = [:]) {
        log(.error, message: message, metadata: metadata)
    }

    func fault(_ message: @autoclosure () -> String, metadata: @autoclosure () -> [String: String] = [:]) {
        log(.fault, message: message, metadata: metadata)
    }

    private func log(_ level: LogLevel, message: () -> String, metadata: () -> [String: String]) {
        guard configuration.allows(channel: channel, level: level) else {
            return
        }

        sink.write(
            LogEvent(
                channel: channel,
                level: level,
                message: message(),
                metadata: metadata()
            )
        )
    }
}
