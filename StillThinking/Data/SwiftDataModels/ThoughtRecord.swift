//
//  ThoughtRecord.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

@Model
final class ThoughtRecord {
    @Attribute(.unique)
    var id: UUID
    var text: String
    var statusRawValue: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ReflectionRecord.thought)
    var reflections: [ReflectionRecord]

    @Relationship(deleteRule: .cascade, inverse: \ReturnScheduleRecord.thought)
    var schedules: [ReturnScheduleRecord]

    init(
        id: UUID,
        text: String,
        statusRawValue: String,
        createdAt: Date,
        updatedAt: Date,
        reflections: [ReflectionRecord] = [],
        schedules: [ReturnScheduleRecord] = []
    ) {
        self.id = id
        self.text = text
        self.statusRawValue = statusRawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reflections = reflections
        self.schedules = schedules
    }
}
