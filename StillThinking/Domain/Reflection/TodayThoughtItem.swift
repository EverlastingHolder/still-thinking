//
//  TodayThoughtItem.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct TodayThoughtItem: Identifiable, Equatable, Sendable {
    let thought: Thought
    let returnedAt: Date?
    let reflectionCount: Int

    var id: UUID {
        thought.id
    }
}
