//
//  AuthenticationAvailability.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

enum AuthenticationAvailability: Equatable, Sendable {
    case available
    case unavailable(String)
}
