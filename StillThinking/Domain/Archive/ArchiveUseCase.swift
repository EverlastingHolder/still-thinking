//
//  ArchiveUseCase.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

@MainActor
final class ArchiveUseCase {
    private let repository: any ThoughtRepository
    private let logger: LoggerClient

    init(repository: any ThoughtRepository, logger: LoggerClient) {
        self.repository = repository
        self.logger = logger
    }

    func loadArchive(
        filter: ArchiveStatusFilter,
        searchText: String
    ) async throws -> [ArchiveThoughtItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var items: [ArchiveThoughtItem] = []

        for status in filter.statuses {
            let thoughts = try await repository.thoughts(with: status)
            for thought in thoughts {
                let reflections = try await repository.reflections(for: thought.id)
                guard query.isEmpty || matches(query: query, thought: thought, reflections: reflections) else {
                    continue
                }

                let lastReflectionDate = reflections.map(\.createdAt).max()
                items.append(
                    ArchiveThoughtItem(
                        thought: thought,
                        reflectionCount: reflections.count,
                        lastActivityAt: max(thought.updatedAt, lastReflectionDate ?? thought.updatedAt)
                    )
                )
            }
        }

        logger.debug("Archive loaded", metadata: ["count": String(items.count)])
        return items.sorted { $0.lastActivityAt > $1.lastActivityAt }
    }

    func loadTimeline(thoughtID: UUID) async throws -> [ThoughtTimelineEntry] {
        guard let thought = try await repository.thought(id: thoughtID) else {
            return []
        }

        let reflections = try await repository.reflections(for: thoughtID)
        let schedules = try await repository.schedules(for: thoughtID)
        var entries = [
            ThoughtTimelineEntry(
                id: thought.id,
                date: thought.createdAt,
                title: "Исходная мысль",
                text: thought.text,
                kind: .thought
            )
        ]

        entries += reflections.map { reflection in
            ThoughtTimelineEntry(
                id: reflection.id,
                date: reflection.createdAt,
                title: "Ответ",
                text: reflection.text,
                kind: .reflection(reflection.opinionState)
            )
        }

        entries += schedules.map { schedule in
            ThoughtTimelineEntry(
                id: schedule.id,
                date: schedule.updatedAt,
                title: schedule.state.title,
                text: schedule.dueAt?.formatted(date: .abbreviated, time: .shortened) ?? "",
                kind: .returnSchedule(schedule.state)
            )
        }

        return entries.sorted { $0.date < $1.date }
    }

    func deleteThought(id: UUID) async throws {
        try await repository.deleteThought(id: id)
        logger.info("Thought deleted from archive")
    }

    private func matches(query: String, thought: Thought, reflections: [Reflection]) -> Bool {
        thought.text.lowercased().contains(query) ||
            reflections.contains { reflection in
                reflection.text.lowercased().contains(query)
            }
    }
}

private extension ReturnScheduleState {
    var title: String {
        switch self {
        case .scheduled:
            "Запланировано"
        case .returned:
            "Вернулась"
        case .cancelled:
            "Отменено"
        }
    }
}
