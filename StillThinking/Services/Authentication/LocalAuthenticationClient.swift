//
//  LocalAuthenticationClient.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import LocalAuthentication

enum LocalAuthenticationClient {
    static func live(contextFactory: @escaping () -> LAContext = LAContext.init) -> AuthenticationClient {
        AuthenticationClient {
            let context = contextFactory()

            // LAContext API остаётся unsafe из-за NSErrorPointer даже при nil.
            if unsafe context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return .available
            }

            return .unavailable(String(localized: "privacyLock.unavailable.defaultReason"))
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
