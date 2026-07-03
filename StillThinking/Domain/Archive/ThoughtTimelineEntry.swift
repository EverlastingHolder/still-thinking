//
//  ThoughtTimelineEntry.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct ThoughtTimelineEntry: Identifiable, Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case thought
        case reflection(OpinionState?)
        case returnSchedule(ReturnScheduleState)
    }

    let id: UUID
    let date: Date
    let title: String
    let text: String
    let kind: Kind
}
