//
//  SettingsModelTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("Настройки")
struct SettingsModelTests {
    @Test("Пауза отменяет pending notifications")
    func pauseCancelsPendingNotifications() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        var schedule = makeSchedule(thoughtID: thought.id)
        schedule.notificationIdentifier = "pending-notification"

        try await fixture.repository.createThought(thought, schedule: schedule)
        await fixture.model.setReturnsPaused(true)

        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(fixture.notifications.cancelledIdentifiers == ["pending-notification"])
        #expect(fixture.notifications.scheduledRequests.isEmpty)
        #expect(storedSchedule.notificationIdentifier == nil)
    }

    @Test("Resume пересоздаёт pending notification")
    func resumeReschedulesPendingNotification() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)

        fixture.store.settings.returnsPaused = true
        try await fixture.repository.createThought(thought, schedule: schedule)
        await fixture.model.setReturnsPaused(false)

        let storedSchedule = try #require(try await fixture.repository.schedules(for: thought.id).first)

        #expect(fixture.notifications.scheduledRequests.map(\.identifier) == [schedule.id.uuidString])
        #expect(storedSchedule.notificationIdentifier == schedule.id.uuidString)
    }

    @Test("Notification privacy setting пересобирает body")
    func notificationPrivacySettingRebuildsBody() async throws {
        let fixture = try makeFixture(notificationStatus: .authorized)
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)

        try await fixture.repository.createThought(thought, schedule: schedule)
        await fixture.model.setShowsThoughtTextInNotifications(true)

        let request = try #require(fixture.notifications.scheduledRequests.first)

        #expect(request.body == thought.text)
    }

    @Test("Разрешённое время переносит уведомление на начало окна")
    func allowedNotificationWindowMovesDateToStartHour() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let fixture = try makeFixture(notificationStatus: .authorized, calendar: calendar)
        let thought = makeThought()
        let schedule = makeSchedule(
            thoughtID: thought.id,
            dueAt: Date(timeIntervalSince1970: 3600)
        )

        try await fixture.repository.createThought(thought, schedule: schedule)
        await fixture.model.setNotificationStartHour(9)

        let request = try #require(fixture.notifications.scheduledRequests.first)
        let hour = calendar.component(.hour, from: request.dueAt)

        #expect(hour == 9)
    }

    @Test("Полное удаление очищает связанные данные")
    func deleteAllDataRemovesRelatedRecords() async throws {
        let fixture = try makeFixture(notificationStatus: .denied)
        let thought = makeThought()
        let schedule = makeSchedule(thoughtID: thought.id)
        let reflection = Reflection(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 3)),
            thoughtID: thought.id,
            text: "Ответ",
            opinionState: .unchanged,
            createdAt: Date(timeIntervalSinceReferenceDate: 20)
        )

        try await fixture.repository.createThought(thought, schedule: schedule)
        try await fixture.repository.addReflection(reflection)
        await fixture.model.deleteAllData()

        #expect(try await fixture.repository.thought(id: thought.id) == nil)
        #expect(try await fixture.repository.schedules(for: thought.id).isEmpty)
        #expect(try await fixture.repository.reflections(for: thought.id).isEmpty)
        #expect(fixture.model.deletionMessage == String(localized: "settings.delete.success"))
    }

    @Test("Ошибка полного удаления отображается безопасно")
    func deleteAllDataErrorIsHandledSafely() async {
        let loggerFactory = LoggerFactory(configuration: .disabled, sink: NoOpLogSink())
        let repository = FailingDeleteRepository()
        let store = AppSettingsStore()
        let scheduler = ReturnScheduler(
            repository: repository,
            notificationClient: .denied,
            settingsStore: store,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 100)),
            logger: loggerFactory.makeLogger(for: .scheduling)
        )
        let model = SettingsModel(
            settingsStore: store,
            repository: repository,
            returnScheduler: scheduler,
            logger: loggerFactory.makeLogger(for: .featureSettings)
        )

        await model.deleteAllData()

        #expect(model.deletionMessage == String(localized: "settings.delete.failed"))
        #expect(model.isDeletingAllData == false)
    }

    private func makeFixture(
        notificationStatus: NotificationAuthorizationStatus,
        calendar: Calendar = .current
    ) throws -> Fixture {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let recorder = RecordingLogSink()
        let loggerFactory = LoggerFactory(
            configuration: LogConfiguration(
                enabledChannels: [.database, .scheduling, .featureSettings],
                minimumLevel: .debug
            ),
            sink: recorder
        )
        let repository = SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
        let store = AppSettingsStore()
        let notifications = RecordingNotificationClient(authorizationStatus: notificationStatus)
        let scheduler = ReturnScheduler(
            repository: repository,
            notificationClient: notifications.client,
            settingsStore: store,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 100)),
            calendar: calendar,
            logger: loggerFactory.makeLogger(for: .scheduling)
        )
        let model = SettingsModel(
            settingsStore: store,
            repository: repository,
            returnScheduler: scheduler,
            logger: loggerFactory.makeLogger(for: .featureSettings)
        )

        return Fixture(
            model: model,
            store: store,
            repository: repository,
            notifications: notifications
        )
    }

    private func makeThought() -> Thought {
        Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 1)),
            text: "Приватная мысль",
            status: .pending,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )
    }

    private func makeSchedule(
        thoughtID: UUID,
        dueAt: Date = Date(timeIntervalSinceReferenceDate: 200)
    ) -> ReturnSchedule {
        ReturnSchedule(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 2)),
            thoughtID: thoughtID,
            dueAt: dueAt,
            state: .scheduled,
            notificationIdentifier: nil,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )
    }

    private struct Fixture {
        let model: SettingsModel
        let store: AppSettingsStore
        let repository: SwiftDataThoughtRepository
        let notifications: RecordingNotificationClient
    }

    private final class FailingDeleteRepository: ThoughtRepository {
        enum Failure: Error {
            case deleteFailed
        }

        func createThought(_ thought: Thought, schedule: ReturnSchedule?) async throws {
        }

        func thought(id: UUID) async throws -> Thought? {
            nil
        }

        func thoughts(with status: ThoughtStatus) async throws -> [Thought] {
            []
        }

        func updateThought(_ thought: Thought) async throws {
        }

        func deleteThought(id: UUID) async throws {
        }

        func deleteAllData() async throws {
            throw Failure.deleteFailed
        }

        func addReflection(_ reflection: Reflection) async throws {
        }

        func reflections(for thoughtID: UUID) async throws -> [Reflection] {
            []
        }

        func recordReflection(
            _ reflection: Reflection,
            updatedThought: Thought,
            nextSchedule: ReturnSchedule?
        ) async throws {
        }

        func updateSchedule(_ schedule: ReturnSchedule) async throws {
        }

        func schedules(for thoughtID: UUID) async throws -> [ReturnSchedule] {
            []
        }

        func schedules(with state: ReturnScheduleState) async throws -> [ReturnSchedule] {
            []
        }

        func schedules(state: ReturnScheduleState, dueOnOrBefore date: Date) async throws -> [ReturnSchedule] {
            []
        }
    }
}
