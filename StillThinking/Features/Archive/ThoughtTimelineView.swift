//
//  ThoughtTimelineView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct ThoughtTimelineView: View {
    @Bindable var model: ThoughtTimelineModel
    @Environment(\.dismiss)
    private var dismiss
    @State private var showsDeleteConfirmation = false

    var body: some View {
        List {
            if model.isLoading {
                ProgressView()
            } else if model.isDeleted {
                ContentUnavailableView("Мысль удалена", systemImage: "trash")
            } else if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            } else if model.entries.isEmpty {
                ContentUnavailableView("История пуста", systemImage: "clock.arrow.circlepath")
            } else {
                ForEach(model.entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(entry.title, systemImage: entry.kind.systemImage)
                            Spacer()
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)

                        if entry.text.isEmpty == false {
                            Text(entry.text)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("История")
        .toolbar {
            Button(role: .destructive) {
                showsDeleteConfirmation = true
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Удалить эту мысль?",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                Task {
                    await model.deleteThought()
                    dismiss()
                }
            }
            Button("Отмена", role: .cancel) {
            }
        } message: {
            Text("Связанные ответы и расписания тоже будут удалены.")
        }
        .task {
            if model.entries.isEmpty {
                await model.load()
            }
        }
        .refreshable {
            await model.load()
        }
    }
}

private extension ThoughtTimelineEntry.Kind {
    var systemImage: String {
        switch self {
        case .thought:
            "square.and.pencil"
        case .reflection:
            "text.bubble"
        case .returnSchedule:
            "calendar.badge.clock"
        }
    }
}

#Preview("История") {
    NavigationStack {
        ThoughtTimelineView(
            model: .preview(
                entries: [
                    .previewThought(),
                    .previewReflection()
                ]
            )
        )
    }
}
