//
//  StillThinkingMigrationPlan.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftData

enum StillThinkingMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [StillThinkingSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
