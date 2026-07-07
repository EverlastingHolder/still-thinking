//
//  OnboardingModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Observation

@MainActor
@Observable
final class OnboardingModel {
    var currentStepIndex: Int
    var hasCompletedOnboarding: Bool

    let steps: [OnboardingStep]

    private let settingsStore: AppSettingsStore

    var currentStep: OnboardingStep {
        steps[currentStepIndex]
    }

    var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }

    init(
        settingsStore: AppSettingsStore,
        currentStepIndex: Int = 0,
        steps: [OnboardingStep] = OnboardingModel.defaultSteps
    ) {
        self.settingsStore = settingsStore
        self.currentStepIndex = min(max(currentStepIndex, 0), max(steps.count - 1, 0))
        self.hasCompletedOnboarding = settingsStore.settings.hasCompletedOnboarding
        self.steps = steps
    }

    func advance() {
        guard isLastStep == false else {
            complete()
            return
        }

        currentStepIndex += 1
    }

    func complete() {
        var settings = settingsStore.settings
        settings.hasCompletedOnboarding = true
        settingsStore.settings = settings
        hasCompletedOnboarding = true
    }
}

private extension OnboardingModel {
    static let defaultSteps: [OnboardingStep] = [
        OnboardingStep(
            id: "capture",
            systemImage: "square.and.pencil",
            titleKey: "onboarding.capture.title",
            messageKey: "onboarding.capture.message"
        ),
        OnboardingStep(
            id: "return",
            systemImage: "calendar.badge.clock",
            titleKey: "onboarding.return.title",
            messageKey: "onboarding.return.message"
        ),
        OnboardingStep(
            id: "reflect",
            systemImage: "lock.shield",
            titleKey: "onboarding.reflect.title",
            messageKey: "onboarding.reflect.message"
        )
    ]
}
