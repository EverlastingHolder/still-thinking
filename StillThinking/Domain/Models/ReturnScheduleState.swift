//
//  ReturnScheduleState.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ReturnScheduleState: String, CaseIterable, Codable, Equatable, Sendable {
    case scheduled
    case returned
    case cancelled
}
