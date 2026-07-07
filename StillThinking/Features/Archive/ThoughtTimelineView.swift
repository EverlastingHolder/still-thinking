//
//  ThoughtTimelineView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct ThoughtTimelineView: View {
    @Bindable var model: ThoughtTimelineModel
    let onDeleted: () -> Void
    @Environment(\.dismiss)
    private var dismiss
    @State private var showsDeleteConfirmation = false

    init(
        model: ThoughtTimelineModel,
        onDeleted: @escaping () -> Void = {}
    ) {
        self.model = model
        self.onDeleted = onDeleted
    }

    var body: some View {
        List {
            if model.isLoading {
                ProgressView()
                    .accessibilityLabel(Text("common.loading"))
            } else if model.isDeleted {
                ContentUnavailableView("timeline.deleted.title", systemImage: "trash")
            } else if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            } else if model.entries.isEmpty {
                ContentUnavailableView("timeline.empty.title", systemImage: "clock.arrow.circlepath")
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
        .navigationTitle("timeline.navigationTitle")
        .toolbar {
            Button(role: .destructive) {
                showsDeleteConfirmation = true
            } label: {
                Label("timeline.delete.button", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "timeline.delete.confirmation.title",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("timeline.delete.button", role: .destructive) {
                Task {
                    await model.deleteThought()
                    onDeleted()
                    dismiss()
                }
            }
            Button("timeline.delete.cancel", role: .cancel) {
            }
        } message: {
            Text("timeline.delete.confirmation.message")
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
