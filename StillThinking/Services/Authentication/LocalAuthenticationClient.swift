//
//  LocalAuthenticationClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import LocalAuthentication

enum LocalAuthenticationClient {
    static func live(contextFactory: @escaping () -> LAContext = LAContext.init) -> AuthenticationClient {
        AuthenticationClient {
            let context = contextFactory()

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return .available
            }

            return .unavailable("Биометрия недоступна или не настроена.")
        } authenticate: { reason in
            let context = contextFactory()

            do {
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                )
            } catch {
                return false
            }
        }
    }
}
