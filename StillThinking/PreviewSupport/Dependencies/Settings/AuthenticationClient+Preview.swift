//
//  AuthenticationClient+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

extension AuthenticationClient {
    static let available = AuthenticationClient {
        .available
    } authenticate: { _ in
        true
    }

    static func unavailable(_ reason: String) -> AuthenticationClient {
        AuthenticationClient {
            .unavailable(reason)
        } authenticate: { _ in
            false
        }
    }
}
