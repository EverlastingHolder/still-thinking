//
//  Reflection.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct Reflection: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let thoughtID: UUID
    var text: String
    var opinionState: OpinionState?
    let createdAt: Date
}
