//
//  AuthenticationClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

struct AuthenticationClient {
    let availability: () -> AuthenticationAvailability
    let authenticate: (String) async -> Bool
}
