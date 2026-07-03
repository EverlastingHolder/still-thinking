//
//  ReflectionRecordMapper.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ReflectionRecordMapper {
    static func makeRecord(from reflection: Reflection, thought: ThoughtRecord) -> ReflectionRecord {
        ReflectionRecord(
            id: reflection.id,
            thoughtID: reflection.thoughtID,
            text: reflection.text,
            opinionStateRawValue: reflection.opinionState?.rawValue,
            createdAt: reflection.createdAt,
            thought: thought
        )
    }

    static func makeDomain(from record: ReflectionRecord) throws -> Reflection {
        let opinionState: OpinionState?

        if let rawValue = record.opinionStateRawValue {
            guard let mappedOpinionState = OpinionState(rawValue: rawValue) else {
                throw PersistenceMappingError.unknownOpinionState(rawValue)
            }

            opinionState = mappedOpinionState
        } else {
            opinionState = nil
        }

        return Reflection(
            id: record.id,
            thoughtID: record.thoughtID,
            text: record.text,
            opinionState: opinionState,
            createdAt: record.createdAt
        )
    }
}
