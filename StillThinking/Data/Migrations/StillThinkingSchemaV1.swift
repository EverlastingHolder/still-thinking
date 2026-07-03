//
//  StillThinkingSchemaV1.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftData

enum StillThinkingSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            ThoughtRecord.self,
            ReflectionRecord.self,
            ReturnScheduleRecord.self
        ]
    }
}
