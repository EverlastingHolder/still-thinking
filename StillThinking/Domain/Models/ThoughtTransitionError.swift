//
//  ThoughtTransitionError.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ThoughtTransitionError: Error, Equatable, Sendable {
    case invalidTransition(from: ThoughtStatus, to: ThoughtStatus)
}
