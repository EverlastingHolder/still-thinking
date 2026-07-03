//
//  ThoughtStatus.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ThoughtStatus: String, CaseIterable, Codable, Equatable, Sendable {
    case pending
    case returned
    case completed
    case released

    var isTerminal: Bool {
        switch self {
        case .pending, .returned:
            false
        case .completed, .released:
            true
        }
    }

    func canTransition(to nextStatus: ThoughtStatus) -> Bool {
        switch (self, nextStatus) {
        case (.pending, .returned),
             (.pending, .completed),
             (.pending, .released),
             (.returned, .pending),
             (.returned, .completed),
             (.returned, .released):
            true
        case let (current, next) where current == next:
            true
        case (.completed, _), (.released, _):
            false
        default:
            false
        }
    }
}
