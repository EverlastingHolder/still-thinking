//
//  ReturnScheduleRecordMapper.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ReturnScheduleRecordMapper {
    static func makeRecord(from schedule: ReturnSchedule, thought: ThoughtRecord) -> ReturnScheduleRecord {
        ReturnScheduleRecord(
            id: schedule.id,
            thoughtID: schedule.thoughtID,
            dueAt: schedule.dueAt,
            stateRawValue: schedule.state.rawValue,
            notificationIdentifier: schedule.notificationIdentifier,
            createdAt: schedule.createdAt,
            updatedAt: schedule.updatedAt,
            thought: thought
        )
    }

    static func makeDomain(from record: ReturnScheduleRecord) throws -> ReturnSchedule {
        guard let state = ReturnScheduleState(rawValue: record.stateRawValue) else {
            throw PersistenceMappingError.unknownReturnScheduleState(record.stateRawValue)
        }

        return ReturnSchedule(
            id: record.id,
            thoughtID: record.thoughtID,
            dueAt: record.dueAt,
            state: state,
            notificationIdentifier: record.notificationIdentifier,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }
}
