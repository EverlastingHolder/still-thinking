//
//  ReturnSchedulerTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("Return scheduler")
struct ReturnSchedulerTests {
    @Test("Планирует нейтральное уведомление и сохраняет identifier")
    func schedulesNeutralNotificationAndStoresIdentifier() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.scheduler.schedule(schedule)

        let request = try #require(fixture.notifications.scheduledRequests.first)
        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(request.title == "Still Thinking")
        #expect(request.body == "У вас есть мысль для возвращения.")
        #expect(request.body.contains(thought.text) == false)
        #expect(storedSchedule.notificationIdentifier == schedule.id.uuidString)
    }

    @Test("Denied permission не ломает сохранённое расписание")
    func deniedPermissionDoesNotBreakSavedSchedule() async throws {
        let fixture = try makeFixture(notificationStatus: .denied)
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.scheduler.schedule(schedule)

        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(fixture.notifications.scheduledRequests.isEmpty)
        #expect(storedSchedule.notificationIdentifier == nil)
    }

    @Test("Not determined permission запрашивается перед планированием")
    func notDeterminedPermissionRequestsAuthorization() async throws {
        let fixture = try makeFixture(notificationStatus: .notDetermined)
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.scheduler.schedule(schedule)

        #expect(fixture.notifications.authorizationRequestCount == 1)
        #expect(fixture.notifications.scheduledRequests.count == 1)
    }

    @Test("Повторное планирование не создаёт второй request")
    func duplicateSchedulingDoesNotCreateSecondRequest() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        var schedule = makeSchedule(thoughtID: thought.id)
        schedule.notificationIdentifier = schedule.id.uuidString

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.scheduler.schedule(schedule)

        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(fixture.notifications.scheduledRequests.isEmpty)
        #expect(storedSchedule.notificationIdentifier == schedule.id.uuidString)
    }

    @Test("Завершённая мысль не получает уведомление")
    func completedThoughtDoesNotReceiveNotification() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought(status: .completed)
        let schedule = makeSchedule(thoughtID: thought.id)

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.scheduler.schedule(schedule)

        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(fixture.notifications.scheduledRequests.isEmpty)
        #expect(storedSchedule.notificationIdentifier == nil)
    }

    @Test("Перенос отменяет старое уведомление и создаёт новое")
    func rescheduleCancelsOldNotificationAndSchedulesNewOne() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        var schedule = makeSchedule(thoughtID: thought.id)
        schedule.notificationIdentifier = "old-notification"

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.scheduler.reschedule(
            schedule,
            dueAt: Date(timeIntervalSinceReferenceDate: 300)
        )

        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(fixture.notifications.cancelledIdentifiers == ["old-notification"])
        #expect(fixture.notifications.scheduledRequests.map(\.dueAt) == [Date(timeIntervalSinceReferenceDate: 300)])
        #expect(storedSchedule.notificationIdentifier == schedule.id.uuidString)
    }

    @Test("Просроченное расписание переводит мысль в returned")
    func overdueScheduleMarksThoughtReturned() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        var schedule = makeSchedule(
            thoughtID: thought.id,
            dueAt: Date(timeIntervalSinceReferenceDate: 50)
        )
        schedule.notificationIdentifier = "pending-overdue-notification"

        try await fixture.repository.createThought(thought, schedule: schedule)
        let returnedIDs = try await fixture.scheduler.markOverdueSchedulesReturned()

        let storedThought = try #require(try await fixture.repository.thought(id: thought.id))
        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(returnedIDs == [thought.id])
        #expect(storedThought.status == .returned)
        #expect(storedSchedule.state == .returned)
        #expect(storedSchedule.notificationIdentifier == nil)
        #expect(fixture.notifications.cancelledIdentifiers == ["pending-overdue-notification"])
    }

    private func makeFixture(notificationStatus: NotificationAuthorizationStatus) throws -> Fixture {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let recorder = RecordingLogSink()
        let loggerFactory = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.database, .scheduling], minimumLevel: .debug),
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

        return Fixture(repository: repository, scheduler: scheduler, notifications: notifications)
    }

    private func makeThought(status: ThoughtStatus = .pending) -> Thought {
        Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1)),
            text: "Приватная мысль",
            status: status,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )
    }

    private func makeSchedule(
        thoughtID: UUID,
        dueAt: Date = Date(timeIntervalSinceReferenceDate: 200)
    ) -> ReturnSchedule {
        ReturnSchedule(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 2)),
            thoughtID: thoughtID,
            dueAt: dueAt,
            state: .scheduled,
            notificationIdentifier: nil,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )
    }

    private struct Fixture {
        let repository: SwiftDataThoughtRepository
        let scheduler: ReturnScheduler
        let notifications: RecordingNotificationClient
    }
}
