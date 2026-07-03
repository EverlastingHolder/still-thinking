//
//  StillThinkingModelContainerFactory.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftData

enum StillThinkingModelContainerFactory {
    static func production() throws -> ModelContainer {
        try makeContainer(isStoredInMemoryOnly: false)
    }

    static func inMemory() throws -> ModelContainer {
        try makeContainer(isStoredInMemoryOnly: true)
    }

    private static func makeContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let schema = Schema(StillThinkingSchemaV1.models)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(
            for: schema,
            migrationPlan: StillThinkingMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
