//
//  TodayReflectionUseCase.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

@MainActor
final class TodayReflectionUseCase {
    private let repository: any ThoughtRepository
    private let returnScheduler: ReturnScheduler
    private let clock: ClockClient
    private let uuidGenerator: UUIDGenerator
    private let logger: LoggerClient

    init(
        repository: any ThoughtRepository,
        returnScheduler: ReturnScheduler,
        clock: ClockClient,
        uuidGenerator: UUIDGenerator,
        logger: LoggerClient
    ) {
        self.repository = repository
        self.returnScheduler = returnScheduler
        self.clock = clock
        self.uuidGenerator = uuidGenerator
        self.logger = logger
    }

    func loadReturnedItems() async throws -> [TodayThoughtItem] {
        _ = try await returnScheduler.markOverdueSchedulesReturned()
        let thoughts = try await repository.thoughts(with: .returned)

        var items: [TodayThoughtItem] = []
        for thought in thoughts {
            let schedules = try await repository.schedules(for: thought.id)
            let reflections = try await repository.reflections(for: thought.id)
            let returnedAt = schedules
                .filter { $0.state == .returned }
                .compactMap(\.dueAt)
                .max()

            items.append(
                TodayThoughtItem(
                    thought: thought,
                    returnedAt: returnedAt,
                    reflectionCount: reflections.count
                )
            )
        }

        return items.sorted { first, second in
            (first.returnedAt ?? first.thought.updatedAt) < (second.returnedAt ?? second.thought.updatedAt)
        }
    }

    func submitReflection(
        thoughtID: UUID,
        text: String,
        opinionState: OpinionState?,
        resolution: ReflectionResolution
    ) async throws {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false else {
            throw TodayReflectionError.invalidReflectionText
        }

        guard let thought = try await repository.thought(id: thoughtID) else {
            throw TodayReflectionError.thoughtNotFound(thoughtID)
        }

        guard thought.status == .returned else {
            throw TodayReflectionError.thoughtIsNotReturned(thoughtID)
        }

        let now = clock.now()
        let nextStatus: ThoughtStatus
        let nextSchedule: ReturnSchedule?

        switch resolution {
        case .complete:
            nextStatus = .completed
            nextSchedule = nil
        case .release:
            nextStatus = .released
            nextSchedule = nil
        case let .reschedule(dueAt):
            nextStatus = .pending
            nextSchedule = ReturnSchedule(
                id: uuidGenerator.make(),
                thoughtID: thoughtID,
                dueAt: dueAt,
                state: .scheduled,
                notificationIdentifier: nil,
                createdAt: now,
                updatedAt: now
            )
        }

        let updatedThought = try thought.transitioning(to: nextStatus, at: now)
        let reflection = Reflection(
            id: uuidGenerator.make(),
            thoughtID: thoughtID,
            text: trimmedText,
            opinionState: opinionState,
            createdAt: now
        )

        try await repository.recordReflection(
            reflection,
            updatedThought: updatedThought,
            nextSchedule: nextSchedule
        )

        if let nextSchedule {
            await scheduleReturn(nextSchedule)
        }
    }

    private func scheduleReturn(_ schedule: ReturnSchedule) async {
        do {
            try await returnScheduler.schedule(schedule)
        } catch {
            logger.error(
                "Reflection reschedule notification failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }
}
