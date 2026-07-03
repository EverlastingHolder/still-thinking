//
//  ArchiveUseCaseTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("Archive and timeline")
struct ArchiveUseCaseTests {
    @Test("Фильтрует архив по статусу")
    func filtersArchiveByStatus() async throws {
        let fixture = try makeFixture()
        let pending = makeThought(idSuffix: 1, text: "Ожидает", status: .pending)
        let completed = makeThought(idSuffix: 2, text: "Завершена", status: .completed)

        try await fixture.repository.createThought(pending, schedule: nil)
        try await fixture.repository.createThought(completed, schedule: nil)

        let items = try await fixture.useCase.loadArchive(filter: .completed, searchText: "")

        #expect(items.map(\.thought.id) == [completed.id])
    }

    @Test("Поиск работает по тексту мысли и reflection")
    func searchesThoughtAndReflectionText() async throws {
        let fixture = try makeFixture()
        let thought = makeThought(idSuffix: 3, text: "Исходный текст", status: .completed)
        let reflection = makeReflection(
            idSuffix: 4,
            thoughtID: thought.id,
            text: "Ответ содержит редкое слово"
        )

        try await fixture.repository.createThought(thought, schedule: nil)
        try await fixture.repository.addReflection(reflection)

        let items = try await fixture.useCase.loadArchive(filter: .all, searchText: "редкое")

        #expect(items.map(\.thought.id) == [thought.id])
        #expect(fixture.logSink.events.flatMap { $0.metadata.values }.contains("редкое") == false)
    }

    @Test("Удалённые записи не появляются в архиве")
    func deletedThoughtDoesNotAppearInArchive() async throws {
        let fixture = try makeFixture()
        let thought = makeThought(idSuffix: 5, text: "Удалить", status: .completed)

        try await fixture.repository.createThought(thought, schedule: nil)
        try await fixture.repository.deleteThought(id: thought.id)

        let items = try await fixture.useCase.loadArchive(filter: .all, searchText: "")

        #expect(items.isEmpty)
    }

    @Test("Timeline сортируется по времени")
    func timelineSortsEntriesByDate() async throws {
        let fixture = try makeFixture()
        let thought = makeThought(idSuffix: 6, text: "Цепочка", status: .completed)
        let schedule = ReturnSchedule(
            id: makeUUID(suffix: 7),
            thoughtID: thought.id,
            dueAt: Date(timeIntervalSinceReferenceDate: 10),
            state: .returned,
            notificationIdentifier: nil,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 10)
        )
        let laterReflection = makeReflection(
            idSuffix: 8,
            thoughtID: thought.id,
            text: "Поздний ответ",
            createdAt: Date(timeIntervalSinceReferenceDate: 30)
        )
        let earlierReflection = makeReflection(
            idSuffix: 9,
            thoughtID: thought.id,
            text: "Ранний ответ",
            createdAt: Date(timeIntervalSinceReferenceDate: 20)
        )

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.repository.addReflection(laterReflection)
        try await fixture.repository.addReflection(earlierReflection)

        let entries = try await fixture.useCase.loadTimeline(thoughtID: thought.id)

        #expect(entries.map(\.date) == [
            Date(timeIntervalSinceReferenceDate: 0),
            Date(timeIntervalSinceReferenceDate: 10),
            Date(timeIntervalSinceReferenceDate: 20),
            Date(timeIntervalSinceReferenceDate: 30)
        ])
    }

    @Test("Длинная цепочка reflection сохраняет порядок в timeline")
    func longReflectionChainKeepsTimelineOrder() async throws {
        let fixture = try makeFixture()
        let thought = makeThought(idSuffix: 10, text: "Длинная цепочка", status: .completed)

        try await fixture.repository.createThought(thought, schedule: nil)
        for index in 0..<8 {
            try await fixture.repository.addReflection(
                makeReflection(
                    idSuffix: 20 + index,
                    thoughtID: thought.id,
                    text: "Ответ \(index)",
                    createdAt: Date(timeIntervalSinceReferenceDate: TimeInterval(index + 1))
                )
            )
        }

        let entries = try await fixture.useCase.loadTimeline(thoughtID: thought.id)

        #expect(entries.map(\.text) == ["Длинная цепочка"] + (0..<8).map { "Ответ \($0)" })
    }

    private func makeFixture() throws -> Fixture {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let logSink = RecordingLogSink()
        let loggerFactory = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.database, .featureArchive], minimumLevel: .debug),
            sink: logSink
        )
        let repository = SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
        let useCase = ArchiveUseCase(
            repository: repository,
            logger: loggerFactory.makeLogger(for: .featureArchive)
        )

        return Fixture(repository: repository, useCase: useCase, logSink: logSink)
    }

    private func makeThought(idSuffix: Int, text: String, status: ThoughtStatus) -> Thought {
        Thought(
            id: makeUUID(suffix: idSuffix),
            text: text,
            status: status,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: TimeInterval(idSuffix))
        )
    }

    private func makeReflection(
        idSuffix: Int,
        thoughtID: UUID,
        text: String,
        createdAt: Date = Date(timeIntervalSinceReferenceDate: 50)
    ) -> Reflection {
        Reflection(
            id: makeUUID(suffix: idSuffix),
            thoughtID: thoughtID,
            text: text,
            opinionState: .unchanged,
            createdAt: createdAt
        )
    }

    private func makeUUID(suffix: Int) -> UUID {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, UInt8(suffix)))
    }

    private struct Fixture {
        let repository: SwiftDataThoughtRepository
        let useCase: ArchiveUseCase
        let logSink: RecordingLogSink
    }
}
