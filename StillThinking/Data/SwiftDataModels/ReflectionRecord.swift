//
//  ReflectionRecord.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

@Model
final class ReflectionRecord {
    @Attribute(.unique)
    var id: UUID
    var thoughtID: UUID
    var text: String
    var opinionStateRawValue: String?
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var thought: ThoughtRecord?

    init(
        id: UUID,
        thoughtID: UUID,
        text: String,
        opinionStateRawValue: String?,
        createdAt: Date,
        thought: ThoughtRecord? = nil
    ) {
        self.id = id
        self.thoughtID = thoughtID
        self.text = text
        self.opinionStateRawValue = opinionStateRawValue
        self.createdAt = createdAt
        self.thought = thought
    }
}
