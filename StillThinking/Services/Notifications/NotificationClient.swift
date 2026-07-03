//
//  NotificationClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

struct NotificationClient {
    let authorizationStatus: () async -> NotificationAuthorizationStatus
    let requestAuthorization: () async throws -> NotificationAuthorizationStatus
    let schedule: (NotificationScheduleRequest) async throws -> Void
    let cancel: ([String]) async -> Void
}
