//
//  TodayReflectionView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct TodayReflectionView: View {
    @Bindable var model: TodayReflectionModel

    var body: some View {
        Form {
            switch model.loadState {
            case .idle, .loading:
                Section {
                    ProgressView()
                }
            case .empty:
                emptySection
            case .failed:
                failedSection
            case .loaded:
                if let item = model.currentItem {
                    thoughtSection(item)
                    promptsSection
                    reflectionSection
                    actionSection
                    saveSection
                } else {
                    emptySection
                }
            }
        }
        .navigationTitle("Сегодня")
        .task {
            if model.loadState == .idle {
                await model.load()
            }
        }
        .task(id: model.nextAutoRefreshDate) {
            await model.waitForNextReturnAndReload()
        }
        .refreshable {
            await model.load()
        }
    }

    private var emptySection: some View {
        Section {
            Label("Нет мыслей для возвращения", systemImage: "checkmark.circle")
                .foregroundStyle(.secondary)
        }
    }

    private var failedSection: some View {
        Section {
            Label("Не удалось загрузить мысли", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)

            Button {
                Task {
                    await model.load()
                }
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
            }
        }
    }

    private func thoughtSection(_ item: TodayThoughtItem) -> some View {
        Section {
            Text(item.thought.text)
                .textSelection(.enabled)

            if let returnedAt = item.returnedAt {
                LabeledContent("Вернулась", value: returnedAt.formatted(date: .abbreviated, time: .shortened))
            }

            if item.reflectionCount > 0 {
                LabeledContent("Ответов", value: "\(item.reflectionCount)")
            }
        } header: {
            Text("Мысль")
        }
    }

    private var promptsSection: some View {
        Section("Вопросы") {
            ForEach(ReflectionPromptLibrary.prompts, id: \.self) { prompt in
                Button {
                    model.applyPrompt(prompt)
                } label: {
                    Label(prompt, systemImage: "text.bubble")
                }
            }
        }
    }

    private var reflectionSection: some View {
        Section {
            TextEditor(text: $model.reflectionText)
                .frame(minHeight: 160)
                .accessibilityLabel("Ответ на вернувшуюся мысль")

            Picker("Мнение", selection: $model.selectedOpinionState) {
                ForEach(OpinionState.allCases, id: \.self) { state in
                    Text(state.title).tag(state)
                }
            }
        } header: {
            Text("Ответ")
        }
    }

    private var actionSection: some View {
        Section("Дальше") {
            Picker("Действие", selection: $model.selectedAction) {
                ForEach(TodayReflectionAction.allCases) { action in
                    Text(action.title).tag(action)
                }
            }
            .pickerStyle(.segmented)

            if model.selectedAction == .reschedule {
                DatePicker(
                    "Вернуть",
                    selection: $model.customReturnDate,
                    in: model.minimumCustomReturnDate...,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }
    }

    private var saveSection: some View {
        Section {
            if let validationMessage = model.validationMessage {
                Text(validationMessage)
                    .foregroundStyle(.red)
                    .accessibilityLabel(validationMessage)
            }

            Button {
                Task {
                    await model.submitCurrentReflection()
                }
            } label: {
                if model.isSaving {
                    ProgressView()
                } else {
                    Label("Сохранить ответ", systemImage: "tray.and.arrow.down")
                }
            }
            .disabled(model.isSaving)
        }
    }
}

private extension OpinionState {
    var title: String {
        switch self {
        case .unchanged:
            "Без изменений"
        case .partiallyChanged:
            "Частично изменилось"
        case .noLongerAgree:
            "Больше не согласен"
        case .unsure:
            "Пока не ясно"
        }
    }
}

#Preview("Пусто") {
    NavigationStack {
        TodayReflectionView(model: .preview(items: []))
    }
}

#Preview("Мысль") {
    NavigationStack {
        TodayReflectionView(model: .preview(items: [.preview()]))
    }
}
