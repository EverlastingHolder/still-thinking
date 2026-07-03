//
//  LoggerFactory.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

struct LoggerFactory {
    let configuration: LogConfiguration
    let sink: any LogSink

    func makeLogger(for channel: LogChannel) -> LoggerClient {
        LoggerClient(channel: channel, configuration: configuration, sink: sink)
    }
}
