//
//  SwiftDataThoughtRepository.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataThoughtRepository: ThoughtRepository {
    private let context: ModelContext
    private let logger: LoggerClient

    init(context: ModelContext, logger: LoggerClient) {
        self.context = context
        self.logger = logger
    }

    func createThought(_ thought: Thought, schedule: ReturnSchedule?) async throws {
        let thoughtRecord = ThoughtRecordMapper.makeRecord(from: thought)
        context.insert(thoughtRecord)

        if let schedule {
            let scheduleRecord = ReturnScheduleRecordMapper.makeRecord(from: schedule, thought: thoughtRecord)
            thoughtRecord.schedules.append(scheduleRecord)
            context.insert(scheduleRecord)
        }

        try save(operation: "createThought", metadata: ["hasSchedule": String(schedule != nil)])
    }

    func thought(id: UUID) async throws -> Thought? {
        guard let record = try fetchThoughtRecord(id: id) else {
            return nil
        }

        return try ThoughtRecordMapper.makeDomain(from: record)
    }

    func thoughts(with status: ThoughtStatus) async throws -> [Thought] {
        let statusRawValue = status.rawValue
        var descriptor = FetchDescriptor<ThoughtRecord>(
            predicate: #Predicate { record in
                record.statusRawValue == statusRawValue
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.includePendingChanges = true

        return try context.fetch(descriptor).map(ThoughtRecordMapper.makeDomain(from:))
    }

    func updateThought(_ thought: Thought) async throws {
        guard let record = try fetchThoughtRecord(id: thought.id) else {
            throw SwiftDataThoughtRepositoryError.thoughtNotFound(thought.id)
        }

        ThoughtRecordMapper.update(record, with: thought)
        try save(operation: "updateThought", metadata: ["status": thought.status.rawValue])
    }

    func deleteThought(id: UUID) async throws {
        guard let record = try fetchThoughtRecord(id: id) else {
            return
        }

        context.delete(record)
        try save(operation: "deleteThought")
    }

    func addReflection(_ reflection: Reflection) async throws {
        guard let thoughtRecord = try fetchThoughtRecord(id: reflection.thoughtID) else {
            throw SwiftDataThoughtRepositoryError.thoughtNotFound(reflection.thoughtID)
        }

        let reflectionRecord = ReflectionRecordMapper.makeRecord(from: reflection, thought: thoughtRecord)
        thoughtRecord.reflections.append(reflectionRecord)
        context.insert(reflectionRecord)
        try save(
            operation: "addReflection",
            metadata: ["hasOpinionState": String(reflection.opinionState != nil)]
        )
    }

    func reflections(for thoughtID: UUID) async throws -> [Reflection] {
        var descriptor = FetchDescriptor<ReflectionRecord>(
            predicate: #Predicate { record in
                record.thoughtID == thoughtID
            },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        descriptor.includePendingChanges = true

        return try context.fetch(descriptor).map(ReflectionRecordMapper.makeDomain(from:))
    }

    func recordReflection(
        _ reflection: Reflection,
        updatedThought: Thought,
        nextSchedule: ReturnSchedule?
    ) async throws {
        guard let thoughtRecord = try fetchThoughtRecord(id: updatedThought.id) else {
            throw SwiftDataThoughtRepositoryError.thoughtNotFound(updatedThought.id)
        }

        ThoughtRecordMapper.update(thoughtRecord, with: updatedThought)

        let reflectionRecord = ReflectionRecordMapper.makeRecord(from: reflection, thought: thoughtRecord)
        thoughtRecord.reflections.append(reflectionRecord)
        context.insert(reflectionRecord)

        if let nextSchedule {
            let scheduleRecord = ReturnScheduleRecordMapper.makeRecord(from: nextSchedule, thought: thoughtRecord)
            thoughtRecord.schedules.append(scheduleRecord)
            context.insert(scheduleRecord)
        }

        try save(
            operation: "recordReflection",
            metadata: [
                "status": updatedThought.status.rawValue,
                "hasNextSchedule": String(nextSchedule != nil)
            ]
        )
    }

    func updateSchedule(_ schedule: ReturnSchedule) async throws {
        guard let record = try fetchScheduleRecord(id: schedule.id) else {
            throw SwiftDataThoughtRepositoryError.scheduleNotFound(schedule.id)
        }

        ReturnScheduleRecordMapper.update(record, with: schedule)
        try save(operation: "updateSchedule", metadata: ["state": schedule.state.rawValue])
    }

    func schedules(for thoughtID: UUID) async throws -> [ReturnSchedule] {
        var descriptor = FetchDescriptor<ReturnScheduleRecord>(
            predicate: #Predicate { record in
                record.thoughtID == thoughtID
            },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        descriptor.includePendingChanges = true

        return try context.fetch(descriptor).map(ReturnScheduleRecordMapper.makeDomain(from:))
    }

    func schedules(state: ReturnScheduleState, dueOnOrBefore date: Date) async throws -> [ReturnSchedule] {
        let stateRawValue = state.rawValue
        var descriptor = FetchDescriptor<ReturnScheduleRecord>(
            predicate: #Predicate { record in
                record.stateRawValue == stateRawValue
            },
            sortBy: [SortDescriptor(\.dueAt)]
        )
        descriptor.includePendingChanges = true

        return try context.fetch(descriptor)
            .map(ReturnScheduleRecordMapper.makeDomain(from:))
            .filter { schedule in
                guard let dueAt = schedule.dueAt else {
                    return false
                }

                return dueAt <= date
            }
    }

    private func fetchThoughtRecord(id: UUID) throws -> ThoughtRecord? {
        var descriptor = FetchDescriptor<ThoughtRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true

        return try context.fetch(descriptor).first
    }

    private func fetchScheduleRecord(id: UUID) throws -> ReturnScheduleRecord? {
        var descriptor = FetchDescriptor<ReturnScheduleRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true

        return try context.fetch(descriptor).first
    }

    private func save(operation: String, metadata: [String: String] = [:]) throws {
        do {
            try context.save()
            logger.info(
                "Database operation completed",
                metadata: metadata.merging(["operation": operation]) { current, _ in current }
            )
        } catch {
            logger.error(
                "Database operation failed",
                metadata: ["operation": operation, "errorType": String(describing: type(of: error))]
            )
            throw error
        }
    }
}
