//
//  ThoughtRecordMapper.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ThoughtRecordMapper {
    static func makeRecord(from thought: Thought) -> ThoughtRecord {
        ThoughtRecord(
            id: thought.id,
            text: thought.text,
            statusRawValue: thought.status.rawValue,
            createdAt: thought.createdAt,
            updatedAt: thought.updatedAt
        )
    }

    static func update(_ record: ThoughtRecord, with thought: Thought) {
        record.text = thought.text
        record.statusRawValue = thought.status.rawValue
        record.createdAt = thought.createdAt
        record.updatedAt = thought.updatedAt
    }

    static func makeDomain(from record: ThoughtRecord) throws -> Thought {
        guard let status = ThoughtStatus(rawValue: record.statusRawValue) else {
            throw PersistenceMappingError.unknownThoughtStatus(record.statusRawValue)
        }

        return Thought(
            id: record.id,
            text: record.text,
            status: status,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }
}
