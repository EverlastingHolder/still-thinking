//
//  ArchiveThoughtItem.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct ArchiveThoughtItem: Identifiable, Equatable, Sendable {
    let thought: Thought
    let reflectionCount: Int
    let lastActivityAt: Date

    var id: UUID {
        thought.id
    }
}
