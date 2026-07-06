//
//  PrivacyLockState.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

enum PrivacyLockState: Equatable, Sendable {
    case unlocked
    case locked
    case unavailable(String)
    case failed
}
