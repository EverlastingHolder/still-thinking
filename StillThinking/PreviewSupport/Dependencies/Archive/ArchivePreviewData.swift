//
//  ArchivePreviewData.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

enum ArchivePreviewData {
}

extension ArchiveThoughtItem {
    static func preview(
        text: String = "Сравнить два решения после разговора и понять, какое всё ещё кажется рабочим."
    ) -> ArchiveThoughtItem {
        let thought = Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 1)),
            text: text,
            status: .completed,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 200)
        )

        return ArchiveThoughtItem(
            thought: thought,
            reflectionCount: 2,
            lastActivityAt: Date(timeIntervalSinceReferenceDate: 200)
        )
    }
}

extension ThoughtTimelineEntry {
    static func previewThought() -> ThoughtTimelineEntry {
        ThoughtTimelineEntry(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 2)),
            date: Date(timeIntervalSinceReferenceDate: 0),
            title: "Исходная мысль",
            text: "Проверить, изменилась ли позиция после паузы.",
            kind: .thought
        )
    }

    static func previewReflection() -> ThoughtTimelineEntry {
        ThoughtTimelineEntry(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 3)),
            date: Date(timeIntervalSinceReferenceDate: 200),
            title: "Ответ",
            text: "Позиция стала спокойнее, но решение всё ещё выглядит верным.",
            kind: .reflection(.partiallyChanged)
        )
    }
}

extension ArchiveModel {
    @MainActor
    static func preview(
        items: [ArchiveThoughtItem],
        searchText: String = ""
    ) -> ArchiveModel {
        let loggerFactory = LoggerFactory(configuration: .disabled, sink: NoOpLogSink())
        let useCase = ArchiveUseCase(
            repository: previewRepository(loggerFactory: loggerFactory),
            logger: loggerFactory.makeLogger(for: .featureArchive)
        )

        return ArchiveModel(
            useCase: useCase,
            logger: loggerFactory.makeLogger(for: .featureArchive),
            items: items,
            searchText: searchText
        )
    }
}

extension ThoughtTimelineModel {
    @MainActor
    static func preview(entries: [ThoughtTimelineEntry]) -> ThoughtTimelineModel {
        let loggerFactory = LoggerFactory(configuration: .disabled, sink: NoOpLogSink())
        return ThoughtTimelineModel(
            thoughtID: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 4)),
            useCase: ArchiveUseCase(
                repository: ArchiveModel.previewRepository(loggerFactory: loggerFactory),
                logger: loggerFactory.makeLogger(for: .featureArchive)
            ),
            logger: loggerFactory.makeLogger(for: .featureArchive),
            entries: entries
        )
    }
}

private extension ArchiveModel {
    @MainActor
    static func previewRepository(loggerFactory: LoggerFactory) -> SwiftDataThoughtRepository {
        let container = PreviewModelContainerFactory.makeContainer()
        return SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
    }
}
