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
        .navigationTitle("Настройки")
        .onAppear {
            model.refreshFromStore()
        }
        .confirmationDialog(
            "Удалить все локальные данные?",
            isPresented: $showsDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Удалить всё", role: .destructive) {
                Task {
                    await model.deleteAllData()
                }
            }
            Button("Отмена", role: .cancel) {
            }
        } message: {
            Text("Будут удалены мысли, ответы и расписания.")
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("Показывать текст мысли", isOn: notificationTextBinding)

            Stepper(
                "С \(model.settings.notificationStartHour):00",
                value: notificationStartBinding,
                in: 0...23
            )

            Stepper(
                "До \(model.settings.notificationEndHour):00",
                value: notificationEndBinding,
                in: (model.settings.notificationStartHour + 1)...24
            )

            Toggle("Пауза возвращений", isOn: returnsPausedBinding)

            if let scheduleUpdateMessage = model.scheduleUpdateMessage {
                Text(scheduleUpdateMessage)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Уведомления")
        } footer: {
            Text("По умолчанию уведомления не раскрывают приватный текст.")
        }
    }

    private var privacySection: some View {
        Section {
            Toggle("Локальная блокировка", isOn: privacyLockBinding)

            switch privacyLockModel.state {
            case .unavailable(let reason):
                Text(reason)
                    .foregroundStyle(.secondary)
            case .failed:
                Text("Не удалось подтвердить доступ.")
                    .foregroundStyle(.secondary)
            case .locked, .unlocked:
                EmptyView()
            }
        } header: {
            Text("Privacy")
        } footer: {
            Text("Блокировка включается вручную и использует биометрию устройства.")
        }
    }

    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                showsDeleteAllConfirmation = true
            } label: {
                if model.isDeletingAllData {
                    ProgressView()
                } else {
                    Label("Удалить все данные", systemImage: "trash")
                }
            }
            .disabled(model.isDeletingAllData)

            if let deletionMessage = model.deletionMessage {
                Text(deletionMessage)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Данные")
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
                Label("Logging", systemImage: "ladybug")
            }
        } header: {
            Text("Developer")
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
