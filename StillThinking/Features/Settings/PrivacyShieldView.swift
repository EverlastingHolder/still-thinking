//
//  PrivacyShieldView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import SwiftUI

struct PrivacyShieldView: View {
    @Bindable var model: PrivacyLockModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("privacyShield.title")
                .font(.title2.bold())

            if model.state == .failed {
                Text("privacyShield.failed.message")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await model.unlock()
                }
            } label: {
                Label("privacyShield.unlock.button", systemImage: "faceid")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

#Preview {
    PrivacyShieldView(
        model: PrivacyLockModel(
            settingsStore: AppSettingsStore(settings: {
                var settings = AppSettings.default
                settings.privacyLockEnabled = true
                return settings
            }()),
            authenticationClient: .available,
            logger: LoggerFactory(configuration: .disabled, sink: NoOpLogSink()).makeLogger(for: .authentication),
            state: .locked
        )
    )
}
