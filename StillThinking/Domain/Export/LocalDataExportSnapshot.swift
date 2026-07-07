//
//  LocalDataExportSnapshot.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Foundation

struct LocalDataExportSnapshot: Codable, Equatable, Sendable {
    let formatVersion: Int
    let exportedAt: Date
    let settings: AppSettings
    let thoughts: [ExportedThought]
}

struct ExportedThought: Codable, Equatable, Sendable {
    let thought: Thought
    let reflections: [Reflection]
    let schedules: [ReturnSchedule]
}
