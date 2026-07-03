//
//  RecordingNotificationClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

@testable import StillThinking

@MainActor
final class RecordingNotificationClient {
    var authorizationStatus: NotificationAuthorizationStatus
    var requestAuthorizationStatus: NotificationAuthorizationStatus
    private(set) var scheduledRequests: [NotificationScheduleRequest] = []
    private(set) var cancelledIdentifiers: [String] = []
    private(set) var authorizationRequestCount = 0

    init(
        authorizationStatus: NotificationAuthorizationStatus,
        requestAuthorizationStatus: NotificationAuthorizationStatus = .authorized
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAuthorizationStatus = requestAuthorizationStatus
    }

    var client: NotificationClient {
        NotificationClient {
            self.authorizationStatus
        } requestAuthorization: {
            self.authorizationRequestCount += 1
            self.authorizationStatus = self.requestAuthorizationStatus
            return self.requestAuthorizationStatus
        } schedule: { request in
            self.scheduledRequests.append(request)
        } cancel: { identifiers in
            self.cancelledIdentifiers.append(contentsOf: identifiers)
        }
    }
}
