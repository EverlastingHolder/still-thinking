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
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text("privacyShield.title")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if model.state == .failed {
                    Text("privacyShield.failed.message")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    Task {
                        await model.unlock()
                    }
                } label: {
                    Label("privacyShield.unlock.button", systemImage: "faceid")
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
            .padding()
            .padding(.vertical, 40)
        }
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

#Preview("English AX failed") {
    PrivacyShieldView(model: .preview(state: .failed))
        .environment(\.locale, Locale(identifier: "en"))
        .dynamicTypeSize(.accessibility3)
}
