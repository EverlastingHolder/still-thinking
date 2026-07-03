//
//  ArchiveView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct ArchiveView: View {
    @Bindable var model: ArchiveModel
    let makeTimelineModel: (UUID) -> ThoughtTimelineModel

    var body: some View {
        List {
            filterSection

            if model.isLoading {
                ProgressView()
            } else if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            } else if model.isEmptySearchResult {
                ContentUnavailableView("Ничего не найдено", systemImage: "magnifyingglass")
            } else if model.items.isEmpty {
                ContentUnavailableView("Архив пуст", systemImage: "archivebox")
            } else {
                archiveItems
            }
        }
        .navigationTitle("Архив")
        .searchable(text: $model.searchText, prompt: "Поиск")
        .onChange(of: model.searchText) {
            Task {
                await model.load()
            }
        }
        .onChange(of: model.selectedFilter) {
            Task {
                await model.load()
            }
        }
        .task {
            if model.items.isEmpty && model.searchText.isEmpty {
                await model.load()
            }
        }
        .refreshable {
            await model.load()
        }
    }

    private var filterSection: some View {
        Section {
            Picker("Статус", selection: $model.selectedFilter) {
                ForEach(ArchiveStatusFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var archiveItems: some View {
        Section {
            ForEach(model.items) { item in
                NavigationLink {
                    ThoughtTimelineView(model: makeTimelineModel(item.thought.id))
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.thought.text)
                            .lineLimit(2)

                        HStack {
                            Label(item.thought.status.title, systemImage: item.thought.status.systemImage)
                            Spacer()
                            Text(item.lastActivityAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        if item.reflectionCount > 0 {
                            Text("Ответов: \(item.reflectionCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

private extension ArchiveStatusFilter {
    var title: String {
        switch self {
        case .all:
            "Все"
        case .pending:
            "Ждут"
        case .returned:
            "Сегодня"
        case .completed:
            "Завершены"
        case .released:
            "Отпущены"
        }
    }
}

private extension ThoughtStatus {
    var title: String {
        switch self {
        case .pending:
            "Ожидает"
        case .returned:
            "Вернулась"
        case .completed:
            "Завершена"
        case .released:
            "Отпущена"
        }
    }

    var systemImage: String {
        switch self {
        case .pending:
            "clock"
        case .returned:
            "calendar"
        case .completed:
            "checkmark.circle"
        case .released:
            "leaf"
        }
    }
}

#Preview("Архив") {
    NavigationStack {
        ArchiveView(
            model: .preview(items: [.preview()]),
            makeTimelineModel: { _ in .preview(entries: [.previewThought()]) }
        )
    }
}

#Preview("Поиск пуст") {
    NavigationStack {
        ArchiveView(
            model: .preview(items: [], searchText: "нет"),
            makeTimelineModel: { _ in .preview(entries: []) }
        )
    }
}
