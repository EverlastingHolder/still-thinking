//
//  PersistenceMappingTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Testing
@testable import StillThinking

@Suite("Mapping persistence моделей")
struct PersistenceMappingTests {
    @Test("ThoughtRecord преобразуется в доменную мысль")
    func thoughtRecordMapsToDomainModel() throws {
        let record = ThoughtRecord(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1)),
            text: "Текст мысли",
            statusRawValue: ThoughtStatus.pending.rawValue,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1)
        )

        let thought = try ThoughtRecordMapper.makeDomain(from: record)

        #expect(thought.status == .pending)
        #expect(thought.text == "Текст мысли")
    }

    @Test("Неизвестный статус мысли возвращает ошибку mapping")
    func unknownThoughtStatusReturnsMappingError() {
        let record = ThoughtRecord(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2)),
            text: "Текст мысли",
            statusRawValue: "unknown",
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1)
        )

        #expect(throws: PersistenceMappingError.unknownThoughtStatus("unknown")) {
            _ = try ThoughtRecordMapper.makeDomain(from: record)
        }
    }

    @Test("ReflectionRecord сохраняет opinion state")
    func reflectionRecordMapsOpinionState() throws {
        let record = ReflectionRecord(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3)),
            thoughtID: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4)),
            text: "Ответ",
            opinionStateRawValue: OpinionState.partiallyChanged.rawValue,
            createdAt: Date(timeIntervalSinceReferenceDate: 2)
        )

        let reflection = try ReflectionRecordMapper.makeDomain(from: record)

        #expect(reflection.opinionState == .partiallyChanged)
    }

    @Test("ReturnScheduleRecord сохраняет state и notification identifier")
    func scheduleRecordMapsStateAndNotificationIdentifier() throws {
        let record = ReturnScheduleRecord(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 5)),
            thoughtID: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 6)),
            dueAt: Date(timeIntervalSinceReferenceDate: 3),
            stateRawValue: ReturnScheduleState.scheduled.rawValue,
            notificationIdentifier: "notification-id",
            createdAt: Date(timeIntervalSinceReferenceDate: 2),
            updatedAt: Date(timeIntervalSinceReferenceDate: 2)
        )

        let schedule = try ReturnScheduleRecordMapper.makeDomain(from: record)

        #expect(schedule.state == .scheduled)
        #expect(schedule.notificationIdentifier == "notification-id")
    }
}
