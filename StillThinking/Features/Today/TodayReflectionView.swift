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
                        .accessibilityLabel(Text("common.loading"))
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
        .navigationTitle("today.navigationTitle")
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
            Label("today.empty.title", systemImage: "checkmark.circle")
                .foregroundStyle(.secondary)
        }
    }

    private var failedSection: some View {
        Section {
            Label("today.failed.title", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)

            Button {
                Task {
                    await model.load()
                }
            } label: {
                Label("today.retry.button", systemImage: "arrow.clockwise")
            }
        }
    }

    private func thoughtSection(_ item: TodayThoughtItem) -> some View {
        Section {
            Text(item.thought.text)
                .textSelection(.enabled)

            if let returnedAt = item.returnedAt {
                LabeledContent(
                    "today.thought.returnedAt",
                    value: returnedAt.formatted(date: .abbreviated, time: .shortened)
                )
            }

            if item.reflectionCount > 0 {
                LabeledContent(
                    "today.thought.reflectionCount",
                    value: "\(item.reflectionCount)"
                )
            }
        } header: {
            Text("today.section.thought")
        }
    }

    private var promptsSection: some View {
        Section("today.section.prompts") {
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
                .accessibilityLabel(Text("today.reflectionText.accessibilityLabel"))

            Picker("today.opinion.picker", selection: $model.selectedOpinionState) {
                ForEach(OpinionState.allCases, id: \.self) { state in
                    Text(state.title).tag(state)
                }
            }
        } header: {
            Text("today.section.reflection")
        }
    }

    private var actionSection: some View {
        Section("today.section.next") {
            Picker("today.action.picker", selection: $model.selectedAction) {
                ForEach(TodayReflectionAction.allCases) { action in
                    Text(action.title).tag(action)
                }
            }
            .pickerStyle(.segmented)

            if model.selectedAction == .reschedule {
                DatePicker(
                    "today.reschedule.date",
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
                        .accessibilityLabel(Text("common.saving"))
                } else {
                    Label("today.save.button", systemImage: "tray.and.arrow.down")
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
            String(localized: "today.opinion.unchanged")
        case .partiallyChanged:
            String(localized: "today.opinion.partiallyChanged")
        case .noLongerAgree:
            String(localized: "today.opinion.noLongerAgree")
        case .unsure:
            String(localized: "today.opinion.unsure")
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
