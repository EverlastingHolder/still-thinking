//
//  ClockClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct ClockClient {
    let now: @Sendable () -> Date

    static let live = ClockClient(now: Date.init)

    static func fixed(_ date: Date) -> ClockClient {
        ClockClient { date }
    }
}
