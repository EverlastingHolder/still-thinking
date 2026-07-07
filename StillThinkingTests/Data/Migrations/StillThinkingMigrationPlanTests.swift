//
//  StillThinkingMigrationPlanTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("Миграции SwiftData")
struct StillThinkingMigrationPlanTests {
    @Test("Baseline V1 содержит текущие модели")
    func baselineSchemaContainsCurrentModels() {
        #expect(StillThinkingSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
        #expect(typeIDs(StillThinkingSchemaV1.models) == [
            ObjectIdentifier(ThoughtRecord.self),
            ObjectIdentifier(ReflectionRecord.self),
            ObjectIdentifier(ReturnScheduleRecord.self)
        ])
        #expect(typeIDs(StillThinkingMigrationPlan.schemas) == [
            ObjectIdentifier(StillThinkingSchemaV1.self)
        ])
        #expect(StillThinkingMigrationPlan.stages.isEmpty)
    }

    @Test("Фабрика открывает записываемый контейнер с migration plan")
    func factoryOpensWritableContainerWithMigrationPlan() throws {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let context = ModelContext(container)
        let thought = ThoughtRecord(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 1)),
            text: "Приватная мысль",
            statusRawValue: ThoughtStatus.pending.rawValue,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )

        context.insert(thought)
        try context.save()

        let descriptor = FetchDescriptor<ThoughtRecord>()
        let storedThought = try #require(try context.fetch(descriptor).first)

        #expect(storedThought.id == thought.id)
        #expect(storedThought.statusRawValue == ThoughtStatus.pending.rawValue)
    }

    private func typeIDs(_ types: [any PersistentModel.Type]) -> [ObjectIdentifier] {
        types.map(ObjectIdentifier.init)
    }

    private func typeIDs(_ types: [any VersionedSchema.Type]) -> [ObjectIdentifier] {
        types.map(ObjectIdentifier.init)
    }
}
