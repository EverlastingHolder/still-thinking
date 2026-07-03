//
//  NoOpLogSink.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

struct NoOpLogSink: LogSink {
    func write(_ event: LogEvent) {}
}
