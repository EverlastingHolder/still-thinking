//
//  LogSink.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

protocol LogSink {
    func write(_ event: LogEvent)
}
