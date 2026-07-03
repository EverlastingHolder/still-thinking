//
//  ReturnSchedule.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct ReturnSchedule: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let thoughtID: UUID
    var dueAt: Date?
    var state: ReturnScheduleState
    var notificationIdentifier: String?
    let createdAt: Date
    var updatedAt: Date
}
