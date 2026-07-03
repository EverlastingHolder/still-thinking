//
//  TodayReflectionUseCaseTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("Today reflection flow")
struct TodayReflectionUseCaseTests {
    @Test("Сохраняет reflection и завершает мысль")
    func savesReflectionAndCompletesThought() async throws {
        let fixture = try makeFixture()
        let thought = makeReturnedThought()
        let schedule = makeReturnedSchedule(thoughtID: thought.id)

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.useCase.submitReflection(
            thoughtID: thought.id,
            text: "Теперь понятно",
            opinionState: .partiallyChanged,
            resolution: .complete
        )

        let storedThought = try #require(try await fixture.repository.thought(id: thought.id))
        let reflections = try await fixture.repository.reflections(for: thought.id)
        let reflection = try #require(reflections.first)

        #expect(storedThought.status == .completed)
        #expect(reflection.text == "Теперь понятно")
        #expect(reflection.opinionState == .partiallyChanged)
    }

    @Test("Release переводит мысль в released")
    func releaseMarksThoughtReleased() async throws {
        let fixture = try makeFixture()
        let thought = makeReturnedThought()

        try await fixture.repository.createThought(thought, schedule: nil)
        try await fixture.useCase.submitReflection(
            thoughtID: thought.id,
            text: "Можно отпустить",
            opinionState: .noLongerAgree,
            resolution: .release
        )

        let storedThought = try #require(try await fixture.repository.thought(id: thought.id))
        let reflection = try #require(try await fixture.repository.reflections(for: thought.id).first)

        #expect(storedThought.status == .released)
        #expect(reflection.opinionState == .noLongerAgree)
    }

    @Test("Reschedule создаёт новое расписание и notification request")
    func rescheduleCreatesNextScheduleAndNotification() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeReturnedThought()
        let returnedSchedule = makeReturnedSchedule(thoughtID: thought.id)
        let nextDueAt = Date(timeIntervalSinceReferenceDate: 500)

        try await fixture.repository.createThought(thought, schedule: returnedSchedule)
        try await fixture.useCase.submitReflection(
            thoughtID: thought.id,
            text: "Вернуться позже",
            opinionState: .unsure,
            resolution: .reschedule(nextDueAt)
        )

        let storedThought = try #require(try await fixture.repository.thought(id: thought.id))
        let schedules = try await fixture.repository.schedules(for: thought.id)
        let nextSchedule = try #require(schedules.first { $0.state == .scheduled })
        let reflections = try await fixture.repository.reflections(for: thought.id)

        #expect(storedThought.status == .pending)
        #expect(nextSchedule.dueAt == nextDueAt)
        #expect(reflections.count == 1)
        #expect(fixture.notifications.scheduledRequests.map(\.identifier) == [nextSchedule.id.uuidString])
    }

    @Test("Повторная обработка returned item не создаёт дубликат")
    func repeatedProcessingDoesNotCreateDuplicateReflection() async throws {
        let fixture = try makeFixture()
        let thought = makeReturnedThought()

        try await fixture.repository.createThought(thought, schedule: nil)
        try await fixture.useCase.submitReflection(
            thoughtID: thought.id,
            text: "Первый ответ",
            opinionState: .unchanged,
            resolution: .complete
        )

        do {
            try await fixture.useCase.submitReflection(
                thoughtID: thought.id,
                text: "Второй ответ",
                opinionState: .unchanged,
                resolution: .complete
            )
            Issue.record("Повторная обработка должна быть отклонена")
        } catch let error as TodayReflectionError {
            #expect(error == .thoughtIsNotReturned(thought.id))
        }

        let reflections = try await fixture.repository.reflections(for: thought.id)

        #expect(reflections.map(\.text) == ["Первый ответ"])
    }

    @Test("Load возвращает только returned мысли")
    func loadReturnsOnlyReturnedThoughts() async throws {
        let fixture = try makeFixture()
        let returnedThought = makeReturnedThought()
        let pendingThought = Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 4)),
            text: "Ожидает",
            status: .pending,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )

        try await fixture.repository.createThought(returnedThought, schedule: makeReturnedSchedule(thoughtID: returnedThought.id))
        try await fixture.repository.createThought(pendingThought, schedule: nil)

        let items = try await fixture.useCase.loadReturnedItems()

        #expect(items.map(\.thought.id) == [returnedThought.id])
    }

    private func makeFixture(
        notificationStatus: NotificationAuthorizationStatus = .denied
    ) throws -> Fixture {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let recorder = RecordingLogSink()
        let loggerFactory = LoggerFactory(
            configuration: LogConfiguration(
                enabledChannels: [.database, .scheduling, .featureReflection],
                minimumLevel: .debug
            ),
            sink: recorder
        )
        let repository = SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
        let notifications = RecordingNotificationClient(authorizationStatus: notificationStatus)
        let scheduler = ReturnScheduler(
            repository: repository,
            notificationClient: notifications.client,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 100)),
            logger: loggerFactory.makeLogger(for: .scheduling)
        )
        let useCase = TodayReflectionUseCase(
            repository: repository,
            returnScheduler: scheduler,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 100)),
            uuidGenerator: .live,
            logger: loggerFactory.makeLogger(for: .featureReflection)
        )

        return Fixture(repository: repository, useCase: useCase, notifications: notifications)
    }

    private func makeReturnedThought() -> Thought {
        Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 1)),
            text: "Вернувшаяся мысль",
            status: .returned,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 50)
        )
    }

    private func makeReturnedSchedule(thoughtID: UUID) -> ReturnSchedule {
        ReturnSchedule(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 2)),
            thoughtID: thoughtID,
            dueAt: Date(timeIntervalSinceReferenceDate: 50),
            state: .returned,
            notificationIdentifier: nil,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 50)
        )
    }

    private struct Fixture {
        let repository: SwiftDataThoughtRepository
        let useCase: TodayReflectionUseCase
        let notifications: RecordingNotificationClient
    }
}
