//
//  SettingsPreviewData.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import SwiftData

enum SettingsPreviewData {
    @MainActor
    static func makeEnvironment() -> AppEnvironment {
        .preview()
    }
}

extension SettingsModel {
    @MainActor
    static func preview() -> SettingsModel {
        let environment = SettingsPreviewData.makeEnvironment()
        return AppCompositionRoot.makeSettingsModel(environment: environment)
    }
}

extension PrivacyLockModel {
    @MainActor
    static func preview(state: PrivacyLockState = .unlocked) -> PrivacyLockModel {
        let environment = SettingsPreviewData.makeEnvironment()
        return PrivacyLockModel(
            settingsStore: environment.settingsStore,
            authenticationClient: environment.authenticationClient,
            logger: environment.loggerFactory.makeLogger(for: .authentication),
            state: state
        )
    }
}

extension DeveloperLoggingModel {
    @MainActor
    static func preview() -> DeveloperLoggingModel {
        DeveloperLoggingModel(store: DebugLogPreferencesStore())
    }
}
