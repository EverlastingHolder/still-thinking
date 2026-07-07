//
//  OnboardingStep.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Foundation

struct OnboardingStep: Equatable, Identifiable, Sendable {
    let id: String
    let systemImage: String
    let titleKey: String
    let messageKey: String
}
