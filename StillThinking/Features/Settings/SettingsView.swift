//
//  SettingsView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var model: SettingsModel
    @Bindable var privacyLockModel: PrivacyLockModel
    let logConfigurationSource: LogConfigurationSource
    let makeDeveloperLoggingModel: () -> DeveloperLoggingModel

    @State private var showsDeleteAllConfirmation = false

    var body: some View {
        Form {
            notificationSection
            privacySection
            dataSection
            #if DEBUG
            developerSection
            #endif
        }
        .navigationTitle("settings.navigationTitle")
        .onAppear {
            model.refreshFromStore()
        }
        .confirmationDialog(
            "settings.delete.confirmation.title",
            isPresented: $showsDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("settings.delete.confirmation.confirm", role: .destructive) {
                Task {
                    await model.deleteAllData()
                }
            }
            Button("settings.delete.confirmation.cancel", role: .cancel) {
            }
        } message: {
            Text("settings.delete.confirmation.message")
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("settings.notifications.showThoughtText", isOn: notificationTextBinding)

            unsafe Stepper(
                String(
                    format: String(localized: "settings.notifications.startHour"),
                    model.settings.notificationStartHour
                ),
                value: notificationStartBinding,
                in: 0...23
            )

            unsafe Stepper(
                String(
                    format: String(localized: "settings.notifications.endHour"),
                    model.settings.notificationEndHour
                ),
                value: notificationEndBinding,
                in: (model.settings.notificationStartHour + 1)...24
            )

            Toggle("settings.notifications.pauseReturns", isOn: returnsPausedBinding)

            if let scheduleUpdateMessage = model.scheduleUpdateMessage {
                Text(scheduleUpdateMessage)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("settings.section.notifications")
        } footer: {
            Text("settings.notifications.footer")
        }
    }

    private var privacySection: some View {
        Section {
            Toggle("settings.privacy.localLock", isOn: privacyLockBinding)

            switch privacyLockModel.state {
            case .unavailable(let reason):
                Text(reason)
                    .foregroundStyle(.secondary)
            case .failed:
                Text("settings.privacy.authFailed")
                    .foregroundStyle(.secondary)
            case .locked, .unlocked:
                EmptyView()
            }
        } header: {
            Text("settings.section.privacy")
        } footer: {
            Text("settings.privacy.footer")
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                Task {
                    await model.prepareDataExport()
                }
            } label: {
                if model.isExportingData {
                    ProgressView()
                        .accessibilityLabel(Text("common.exporting"))
                } else {
                    Label("settings.export.button", systemImage: "square.and.arrow.up")
                }
            }
            .disabled(model.isExportingData)

            if let exportFileURL = model.exportFileURL {
                ShareLink(item: exportFileURL) {
                    Label("settings.export.share", systemImage: "square.and.arrow.up")
                }
            }

            if let exportMessage = model.exportMessage {
                Text(exportMessage)
                    .foregroundStyle(.secondary)
            }

            Button(role: .destructive) {
                showsDeleteAllConfirmation = true
            } label: {
                if model.isDeletingAllData {
                    ProgressView()
                        .accessibilityLabel(Text("common.deleting"))
                } else {
                    Label("settings.delete.button", systemImage: "trash")
                }
            }
            .disabled(model.isDeletingAllData)

            if let deletionMessage = model.deletionMessage {
                Text(deletionMessage)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("settings.section.data")
        }
    }

    #if DEBUG
    private var developerSection: some View {
        Section {
            NavigationLink {
                DeveloperLoggingView(
                    model: makeDeveloperLoggingModel(),
                    activeSource: logConfigurationSource
                )
            } label: {
                Label("settings.developer.logging", systemImage: "ladybug")
            }
        } header: {
            Text("settings.section.developer")
        }
    }
    #endif

    private var notificationTextBinding: Binding<Bool> {
        Binding {
            model.settings.showsThoughtTextInNotifications
        } set: { value in
            Task {
                await model.setShowsThoughtTextInNotifications(value)
            }
        }
    }

    private var returnsPausedBinding: Binding<Bool> {
        Binding {
            model.settings.returnsPaused
        } set: { value in
            Task {
                await model.setReturnsPaused(value)
            }
        }
    }

    private var notificationStartBinding: Binding<Int> {
        Binding {
            model.settings.notificationStartHour
        } set: { value in
            Task {
                await model.setNotificationStartHour(value)
            }
        }
    }

    private var notificationEndBinding: Binding<Int> {
        Binding {
            model.settings.notificationEndHour
        } set: { value in
            Task {
                await model.setNotificationEndHour(value)
            }
        }
    }

    private var privacyLockBinding: Binding<Bool> {
        Binding {
            model.settings.privacyLockEnabled
        } set: { value in
            Task {
                await privacyLockModel.setEnabled(value)
                model.refreshFromStore()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            model: .preview(),
            privacyLockModel: .preview(),
            logConfigurationSource: .projectDefault,
            makeDeveloperLoggingModel: { .preview() }
        )
    }
}

#Preview("English AX") {
    NavigationStack {
        SettingsView(
            model: .preview(),
            privacyLockModel: .preview(state: .unavailable("Biometrics are not available on this device.")),
            logConfigurationSource: .environment,
            makeDeveloperLoggingModel: { .preview() }
        )
    }
    .environment(\.locale, Locale(identifier: "en"))
    .dynamicTypeSize(.accessibility3)
}
