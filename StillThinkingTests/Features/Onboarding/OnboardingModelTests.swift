//
//  OnboardingModelTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Testing
@testable import StillThinking

@MainActor
@Suite("Onboarding")
struct OnboardingModelTests {
    @Test("Первый запуск показывает onboarding")
    func firstLaunchShowsOnboarding() {
        let model = OnboardingModel(settingsStore: AppSettingsStore())

        #expect(model.hasCompletedOnboarding == false)
        #expect(model.currentStepIndex == 0)
    }

    @Test("Последний шаг сохраняет прохождение")
    func lastStepPersistsCompletion() {
        let store = AppSettingsStore()
        let model = OnboardingModel(settingsStore: store, currentStepIndex: 2)

        model.advance()

        #expect(model.hasCompletedOnboarding)
        #expect(store.settings.hasCompletedOnboarding)
    }

    @Test("Повторный запуск читает сохранённое прохождение")
    func repeatedLaunchReadsPersistedCompletion() {
        var settings = AppSettings.default
        settings.hasCompletedOnboarding = true
        let store = AppSettingsStore(settings: settings)
        let model = OnboardingModel(settingsStore: store)

        #expect(model.hasCompletedOnboarding)
    }
}
