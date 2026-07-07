//
//  ReturnScheduler.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

@MainActor
final class ReturnScheduler {
    private let repository: any ThoughtRepository
    private let notificationClient: NotificationClient
    private let settingsStore: AppSettingsStore
    private let clock: ClockClient
    private let calendar: Calendar
    private let logger: LoggerClient

    init(
        repository: any ThoughtRepository,
        notificationClient: NotificationClient,
        settingsStore: AppSettingsStore = AppSettingsStore(),
        clock: ClockClient,
        calendar: Calendar = .current,
        logger: LoggerClient
    ) {
        self.repository = repository
        self.notificationClient = notificationClient
        self.settingsStore = settingsStore
        self.clock = clock
        self.calendar = calendar
        self.logger = logger
    }

    func schedule(_ schedule: ReturnSchedule) async throws {
        guard schedule.notificationIdentifier == nil else {
            logger.debug("Return notification already scheduled")
            return
        }

        try await scheduleNotification(for: schedule)
    }

    func reschedule(_ schedule: ReturnSchedule, dueAt: Date?) async throws {
        if let notificationIdentifier = schedule.notificationIdentifier {
            await notificationClient.cancel([notificationIdentifier])
        }

        var updatedSchedule = schedule
        updatedSchedule.dueAt = dueAt
        updatedSchedule.state = .scheduled
        updatedSchedule.notificationIdentifier = nil
        updatedSchedule.updatedAt = clock.now()

        try await repository.updateSchedule(updatedSchedule)
        try await scheduleNotification(for: updatedSchedule)
    }

    func cancel(_ schedule: ReturnSchedule) async throws {
        if let notificationIdentifier = schedule.notificationIdentifier {
            await notificationClient.cancel([notificationIdentifier])
        }

        var cancelledSchedule = schedule
        cancelledSchedule.state = .cancelled
        cancelledSchedule.notificationIdentifier = nil
        cancelledSchedule.updatedAt = clock.now()
        try await repository.updateSchedule(cancelledSchedule)
    }

    func rebuildPendingNotifications() async throws {
        let schedules = try await repository.schedules(with: .scheduled)

        for schedule in schedules {
            if let notificationIdentifier = schedule.notificationIdentifier {
                await notificationClient.cancel([notificationIdentifier])
            }

            var updatedSchedule = schedule
            updatedSchedule.notificationIdentifier = nil
            updatedSchedule.updatedAt = clock.now()
            try await repository.updateSchedule(updatedSchedule)
            try await scheduleNotification(for: updatedSchedule)
        }

        logger.info("Pending return notifications rebuilt", metadata: ["count": String(schedules.count)])
    }

    func markOverdueSchedulesReturned() async throws -> [UUID] {
        guard settingsStore.settings.returnsPaused == false else {
            logger.notice("Return processing skipped while returns are paused")
            return []
        }

        let now = clock.now()
        let schedules = try await repository.schedules(state: .scheduled, dueOnOrBefore: now)
        var returnedThoughtIDs: [UUID] = []

        for schedule in schedules {
            guard var thought = try await repository.thought(id: schedule.thoughtID),
                  thought.status.canTransition(to: .returned) else {
                continue
            }

            if let notificationIdentifier = schedule.notificationIdentifier {
                await notificationClient.cancel([notificationIdentifier])
            }

            var returnedSchedule = schedule
            returnedSchedule.state = .returned
            returnedSchedule.notificationIdentifier = nil
            returnedSchedule.updatedAt = now
            try await repository.updateSchedule(returnedSchedule)

            thought = try thought.transitioning(to: .returned, at: now)
            try await repository.updateThought(thought)
            returnedThoughtIDs.append(thought.id)
        }

        logger.info("Overdue return schedules processed", metadata: ["count": String(returnedThoughtIDs.count)])
        return returnedThoughtIDs
    }

    private func scheduleNotification(for schedule: ReturnSchedule) async throws {
        let settings = settingsStore.settings
        guard settings.returnsPaused == false else {
            logger.notice("Return notification skipped while returns are paused")
            return
        }

        guard let dueAt = schedule.dueAt else {
            logger.notice("Return schedule has no exact due date")
            return
        }

        guard let thought = try await repository.thought(id: schedule.thoughtID),
              thought.status.isTerminal == false else {
            logger.notice("Return notification skipped for inactive thought")
            return
        }

        let status = try await resolvedAuthorizationStatus()
        guard status.allowsScheduling else {
            logger.notice("Notification permission does not allow scheduling", metadata: ["status": "\(status)"])
            return
        }

        let identifier = schedule.id.uuidString
        let notificationDate = settings.notificationDate(for: dueAt, calendar: calendar)
        try await notificationClient.schedule(
            NotificationScheduleRequest(
                identifier: identifier,
                dueAt: notificationDate,
                title: "Still Thinking",
                body: settings.showsThoughtTextInNotifications
                    ? thought.text
                    : String(localized: "notifications.return.body")
            )
        )

        var scheduled = schedule
        scheduled.notificationIdentifier = identifier
        scheduled.updatedAt = clock.now()
        try await repository.updateSchedule(scheduled)
        logger.info("Return notification scheduled")
    }

    private func resolvedAuthorizationStatus() async throws -> NotificationAuthorizationStatus {
        let currentStatus = await notificationClient.authorizationStatus()
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        return try await notificationClient.requestAuthorization()
    }
}
