//
//  NotificationScheduleRequest.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct NotificationScheduleRequest: Equatable, Sendable {
    let identifier: String
    let dueAt: Date
    let title: String
    let body: String
}
