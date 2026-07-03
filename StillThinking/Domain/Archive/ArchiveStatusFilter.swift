//
//  ArchiveStatusFilter.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ArchiveStatusFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case pending
    case returned
    case completed
    case released

    var id: String {
        rawValue
    }

    var statuses: [ThoughtStatus] {
        switch self {
        case .all:
            ThoughtStatus.allCases
        case .pending:
            [.pending]
        case .returned:
            [.returned]
        case .completed:
            [.completed]
        case .released:
            [.released]
        }
    }
}
