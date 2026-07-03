//
//  SwiftDataThoughtRepositoryTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("SwiftData repository мыслей")
struct SwiftDataThoughtRepositoryTests {
    @Test("Создаёт и читает мысль с расписанием")
    func createsAndReadsThoughtWithSchedule() async throws {
        let repository = try makeRepository()
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)

        try await repository.createThought(thought, schedule: schedule)

        let storedThought = try await repository.thought(id: thought.id)
        let schedules = try await repository.schedules(for: thought.id)

        #expect(storedThought == thought)
        #expect(schedules == [schedule])
    }

    @Test("Сохраняет reflections в порядке создания")
    func savesReflectionsInCreationOrder() async throws {
        let repository = try makeRepository()
        let thought = makeThought()
        let firstReflection = makeReflection(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3)),
            thoughtID: thought.id,
            text: "Первый ответ",
            createdAt: Date(timeIntervalSinceReferenceDate: 20)
        )
        let secondReflection = makeReflection(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4)),
            thoughtID: thought.id,
            text: "Второй ответ",
            createdAt: Date(timeIntervalSinceReferenceDate: 30)
        )

        try await repository.createThought(thought, schedule: nil)
        try await repository.addReflection(secondReflection)
        try await repository.addReflection(firstReflection)

        let reflections = try await repository.reflections(for: thought.id)

        #expect(reflections == [firstReflection, secondReflection])
    }

    @Test("Обновляет статус мысли")
    func updatesThoughtStatus() async throws {
        let repository = try makeRepository()
        let thought = makeThought()
        let returnedThought = try thought.transitioning(
            to: .returned,
            at: Date(timeIntervalSinceReferenceDate: 40)
        )

        try await repository.createThought(thought, schedule: nil)
        try await repository.updateThought(returnedThought)

        let storedThought = try await repository.thought(id: thought.id)

        #expect(storedThought?.status == .returned)
        #expect(storedThought?.updatedAt == Date(timeIntervalSinceReferenceDate: 40))
    }

    @Test("Удаление мысли удаляет связанные reflections и schedules")
    func deletingThoughtRemovesRelatedRecords() async throws {
        let repository = try makeRepository()
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)
        let reflection = makeReflection(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5)),
            thoughtID: thought.id,
            text: "Ответ",
            createdAt: Date(timeIntervalSinceReferenceDate: 50)
        )

        try await repository.createThought(thought, schedule: schedule)
        try await repository.addReflection(reflection)
        try await repository.deleteThought(id: thought.id)

        let storedThought = try await repository.thought(id: thought.id)
        let reflections = try await repository.reflections(for: thought.id)
        let schedules = try await repository.schedules(for: thought.id)

        #expect(storedThought == nil)
        #expect(reflections.isEmpty)
        #expect(schedules.isEmpty)
    }

    @Test("Repository пишет database events без пользовательского текста")
    func repositoryWritesDatabaseEventsWithoutUserContent() async throws {
        let recorder = RecordingLogSink()
        let repository = try makeRepository(logSink: recorder)
        let thought = makeThought(text: "Приватный текст")

        try await repository.createThought(thought, schedule: nil)

        let event = try #require(recorder.events.first)
        #expect(event.channel == .database)
        #expect(event.message == "Database operation completed")
        #expect(event.metadata["operation"] == "createThought")
        #expect(event.metadata.values.contains("Приватный текст") == false)
    }

    private func makeRepository(logSink: RecordingLogSink = RecordingLogSink()) throws -> SwiftDataThoughtRepository {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let logger = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.database], minimumLevel: .debug),
            sink: logSink
        ).makeLogger(for: .database)

        return SwiftDataThoughtRepository(context: ModelContext(container), logger: logger)
    }

    private func makeThought(text: String = "Текст мысли") -> Thought {
        Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1)),
            text: text,
            status: .pending,
            createdAt: Date(timeIntervalSinceReferenceDate: 10),
            updatedAt: Date(timeIntervalSinceReferenceDate: 10)
        )
    }

    private func makeSchedule(thoughtID: UUID) -> ReturnSchedule {
        ReturnSchedule(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2)),
            thoughtID: thoughtID,
            dueAt: Date(timeIntervalSinceReferenceDate: 100),
            state: .scheduled,
            notificationIdentifier: "notification-id",
            createdAt: Date(timeIntervalSinceReferenceDate: 10),
            updatedAt: Date(timeIntervalSinceReferenceDate: 10)
        )
    }

    private func makeReflection(
        id: UUID,
        thoughtID: UUID,
        text: String,
        createdAt: Date
    ) -> Reflection {
        Reflection(
            id: id,
            thoughtID: thoughtID,
            text: text,
            opinionState: .unchanged,
            createdAt: createdAt
        )
    }
}
