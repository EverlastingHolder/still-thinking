//
//  ReturnScheduleRecord.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

@Model
final class ReturnScheduleRecord {
    @Attribute(.unique)
    var id: UUID
    var thoughtID: UUID
    var dueAt: Date?
    var stateRawValue: String
    var notificationIdentifier: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify)
    var thought: ThoughtRecord?

    init(
        id: UUID,
        thoughtID: UUID,
        dueAt: Date?,
        stateRawValue: String,
        notificationIdentifier: String?,
        createdAt: Date,
        updatedAt: Date,
        thought: ThoughtRecord? = nil
    ) {
        self.id = id
        self.thoughtID = thoughtID
        self.dueAt = dueAt
        self.stateRawValue = stateRawValue
        self.notificationIdentifier = notificationIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.thought = thought
    }
}
