//
//  PrivacyLockModelTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import Testing
@testable import StillThinking

@MainActor
@Suite("Локальная блокировка")
struct PrivacyLockModelTests {
    @Test("Успешная аутентификация включает lock")
    func successfulAuthenticationEnablesLock() async {
        let store = AppSettingsStore()
        let model = makeModel(store: store, client: .available)

        await model.setEnabled(true)

        #expect(store.settings.privacyLockEnabled)
        #expect(model.state == .unlocked)
    }

    @Test("Недоступная биометрия оставляет понятный fallback")
    func unavailableBiometricsLeavesFallback() async {
        let store = AppSettingsStore()
        let model = makeModel(store: store, client: .unavailable("Face ID недоступен"))

        await model.setEnabled(true)

        #expect(store.settings.privacyLockEnabled == false)
        #expect(model.state == .unavailable("Face ID недоступен"))
    }

    @Test("Background lock требует unlock")
    func backgroundLockRequiresUnlock() async {
        let store = AppSettingsStore(settings: {
            var settings = AppSettings.default
            settings.privacyLockEnabled = true
            return settings
        }())
        let model = makeModel(store: store, client: .available)

        model.lockIfNeeded()
        await model.unlock()

        #expect(model.state == .unlocked)
    }

    @Test("Биометрия получает локализованные причины")
    func authenticationUsesLocalizedReasons() async {
        var reasons: [String] = []
        let store = AppSettingsStore(settings: {
            var settings = AppSettings.default
            settings.privacyLockEnabled = true
            return settings
        }())
        let client = AuthenticationClient {
            .available
        } authenticate: { reason in
            reasons.append(reason)
            return true
        }
        let model = makeModel(store: store, client: client)

        await model.setEnabled(true)
        model.lockIfNeeded()
        await model.unlock()

        #expect(reasons == [
            String(localized: "privacyLock.reason.enable"),
            String(localized: "privacyLock.reason.unlock")
        ])
    }

    private func makeModel(store: AppSettingsStore, client: AuthenticationClient) -> PrivacyLockModel {
        PrivacyLockModel(
            settingsStore: store,
            authenticationClient: client,
            logger: LoggerFactory(configuration: .disabled, sink: NoOpLogSink()).makeLogger(for: .authentication)
        )
    }
}
