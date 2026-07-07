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
                ContentUnavailableView("archive.emptySearch.title", systemImage: "magnifyingglass")
            } else if model.items.isEmpty {
                ContentUnavailableView("archive.empty.title", systemImage: "archivebox")
            } else {
                archiveItems
            }
        }
        .navigationTitle("archive.navigationTitle")
        .searchable(text: $model.searchText, prompt: "archive.search.prompt")
        .task(id: model.searchText) {
            await model.load()
        }
        .task(id: model.selectedFilter) {
            await model.load()
        }
        .onAppear {
            model.currentTime = .now
        }
        .task(id: model.currentTime) {
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
            Picker("archive.filter.status", selection: $model.selectedFilter) {
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
                    ThoughtTimelineView(
                        model: makeTimelineModel(item.thought.id),
                        onDeleted: {
                            Task {
                                await model.load()
                            }
                        }
                    )
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
                            unsafe Text(
                                String(
                                    format: String(localized: "archive.reflectionCount"),
                                    item.reflectionCount
                                )
                            )
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
            String(localized: "archive.filter.all")
        case .pending:
            String(localized: "archive.filter.pending")
        case .returned:
            String(localized: "archive.filter.returned")
        case .completed:
            String(localized: "archive.filter.completed")
        case .released:
            String(localized: "archive.filter.released")
        }
    }
}

private extension ThoughtStatus {
    var title: String {
        switch self {
        case .pending:
            String(localized: "archive.status.pending")
        case .returned:
            String(localized: "archive.status.returned")
        case .completed:
            String(localized: "archive.status.completed")
        case .released:
            String(localized: "archive.status.released")
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
