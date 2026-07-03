//
//  Thought.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct Thought: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var text: String
    var status: ThoughtStatus
    let createdAt: Date
    var updatedAt: Date

    func transitioning(to nextStatus: ThoughtStatus, at date: Date) throws -> Thought {
        guard status.canTransition(to: nextStatus) else {
            throw ThoughtTransitionError.invalidTransition(from: status, to: nextStatus)
        }

        var thought = self
        thought.status = nextStatus
        thought.updatedAt = date
        return thought
    }
}
