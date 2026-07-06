//
//  ThoughtCaptureView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct ThoughtCaptureView: View {
    @Bindable var model: ThoughtCaptureModel
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        Form {
            Section {
                ZStack(alignment: .topLeading) {
                    if model.text.isEmpty {
                        Text("Что стоит вернуть позже?")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $model.text)
                        .focused($isTextEditorFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .accessibilityLabel("Текст мысли")
                }
            } header: {
                Text("Мысль")
            } footer: {
                Text("Запишите незавершённую мысль. Она вернётся в выбранный срок.")
            }

            Section("Вернуть") {
                Picker("Срок", selection: $model.selectedPreset) {
                    ForEach(ThoughtReturnPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .pickerStyle(.segmented)

                if model.selectedPreset == .custom {
                    DatePicker(
                        "Дата",
                        selection: $model.customReturnDate,
                        in: model.minimumCustomReturnDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            if let validationMessage = model.validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                        .accessibilityLabel(validationMessage)
                }
            }

            Section {
                Button {
                    Task {
                        await model.save()
                    }
                } label: {
                    if model.isSaving {
                        ProgressView()
                    } else {
                        Label("Сохранить", systemImage: "tray.and.arrow.down")
                    }
                }
                .disabled(model.canSave == false)

                if model.saveState == .saved {
                    Label("Сохранено", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                }
            } footer: {
                Text("Ожидают возвращения: \(model.pendingThoughtCount)")
            }
        }
        .navigationTitle("Still Thinking")
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            isTextEditorFocused = false
        }
        .task {
            await model.loadPendingThoughtCount()
        }
    }
}

#Preview("Пусто") {
    NavigationStack {
        ThoughtCaptureView(model: .preview())
    }
}

#Preview("Длинный текст") {
    NavigationStack {
        ThoughtCaptureView(
            model: .preview(
                text: """
                Я продолжаю возвращаться к этой идее, потому что в ней есть несколько несвязанных пока частей:
                решение, сомнение и ощущение, что ответ появится позже.
                """,
                pendingThoughtCount: 3
            )
        )
    }
}

#Preview("Ошибка") {
    NavigationStack {
        ThoughtCaptureView(
            model: .preview(
                validationMessage: "Введите мысль, которую хотите вернуть позже."
            )
        )
    }
    .preferredColorScheme(.dark)
}
