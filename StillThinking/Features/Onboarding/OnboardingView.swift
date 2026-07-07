//
//  OnboardingView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Bindable var model: OnboardingModel

    var body: some View {
        VStack {
            TabView(selection: $model.currentStepIndex) {
                ForEach(Array(model.steps.enumerated()), id: \.element.id) { index, step in
                    OnboardingStepView(step: step)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            progressText
                .font(.footnote)
                .foregroundStyle(.secondary)

            actionBar
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    private var progressText: Text {
        Text("onboarding.progress.step")
            + Text(" \(model.currentStepIndex + 1) ")
            + Text("onboarding.progress.of")
            + Text(" \(model.steps.count)")
    }

    private var actionBar: some View {
        VStack(spacing: 12) {
            Button {
                model.advance()
            } label: {
                Text(LocalizedStringKey(model.isLastStep ? "onboarding.button.start" : "onboarding.button.next"))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if model.isLastStep == false {
                Button {
                    model.complete()
                } label: {
                    Text("onboarding.button.skip")
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

private struct OnboardingStepView: View {
    let step: OnboardingStep

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: step.systemImage)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text(LocalizedStringKey(step.titleKey))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(LocalizedStringKey(step.messageKey))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Первый экран") {
    OnboardingView(
        model: OnboardingModel(settingsStore: AppSettingsStore())
    )
}

#Preview("Последний экран") {
    OnboardingView(
        model: OnboardingModel(
            settingsStore: AppSettingsStore(),
            currentStepIndex: 2
        )
    )
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility2)
}

#Preview("English") {
    OnboardingView(
        model: OnboardingModel(settingsStore: AppSettingsStore())
    )
    .environment(\.locale, Locale(identifier: "en"))
}

#Preview("English AX") {
    OnboardingView(
        model: OnboardingModel(
            settingsStore: AppSettingsStore(),
            currentStepIndex: 2
        )
    )
    .environment(\.locale, Locale(identifier: "en"))
    .dynamicTypeSize(.accessibility3)
}
