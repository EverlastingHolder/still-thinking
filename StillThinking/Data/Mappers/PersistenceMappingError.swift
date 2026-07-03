//
//  PersistenceMappingError.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum PersistenceMappingError: Error, Equatable, Sendable {
    case unknownThoughtStatus(String)
    case unknownOpinionState(String)
    case unknownReturnScheduleState(String)
}
