//
//  PrivacyLockModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Observation

@MainActor
@Observable
final class PrivacyLockModel {
    var state: PrivacyLockState

    private let settingsStore: AppSettingsStore
    private let authenticationClient: AuthenticationClient
    private let logger: LoggerClient

    init(
        settingsStore: AppSettingsStore,
        authenticationClient: AuthenticationClient,
        logger: LoggerClient,
        state: PrivacyLockState = .unlocked
    ) {
        self.settingsStore = settingsStore
        self.authenticationClient = authenticationClient
        self.logger = logger
        self.state = state
    }

    func setEnabled(_ isEnabled: Bool) async {
        guard isEnabled else {
            var settings = settingsStore.settings
            settings.privacyLockEnabled = false
            settingsStore.settings = settings
            state = .unlocked
            return
        }

        switch authenticationClient.availability() {
        case .available:
            let authenticated = await authenticationClient.authenticate("Включить локальную блокировку Still Thinking")
            guard authenticated else {
                state = .failed
                logger.notice("Privacy lock enabling authentication failed")
                return
            }

            var settings = settingsStore.settings
            settings.privacyLockEnabled = true
            settingsStore.settings = settings
            state = .unlocked
        case let .unavailable(reason):
            var settings = settingsStore.settings
            settings.privacyLockEnabled = false
            settingsStore.settings = settings
            state = .unavailable(reason)
        }
    }

    func lockIfNeeded() {
        guard settingsStore.settings.privacyLockEnabled else {
            return
        }

        state = .locked
    }

    func unlock() async {
        guard settingsStore.settings.privacyLockEnabled else {
            state = .unlocked
            return
        }

        let authenticated = await authenticationClient.authenticate("Разблокировать Still Thinking")
        state = authenticated ? .unlocked : .failed
    }
}
