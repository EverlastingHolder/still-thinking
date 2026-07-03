//
//  RecordingLogSink.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

@testable import StillThinking

final class RecordingLogSink: LogSink {
    private(set) var events: [LogEvent] = []

    func write(_ event: LogEvent) {
        events.append(event)
    }
}
