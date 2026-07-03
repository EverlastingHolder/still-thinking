//
//  OpinionState.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum OpinionState: String, CaseIterable, Codable, Equatable, Sendable {
    case unchanged
    case partiallyChanged
    case noLongerAgree
    case unsure
}
