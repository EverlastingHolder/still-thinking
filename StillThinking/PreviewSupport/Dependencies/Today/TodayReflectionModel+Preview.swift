//
//  TodayReflectionModel+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

extension TodayReflectionModel {
    @MainActor
    static func preview(items: [TodayThoughtItem]) -> TodayReflectionModel {
        let loggerFactory = LoggerFactory(configuration: .disabled, sink: NoOpLogSink())
        let container = PreviewModelContainerFactory.makeContainer()
        let repository = SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
        let scheduler = ReturnScheduler(
            repository: repository,
            notificationClient: .denied,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
            logger: loggerFactory.makeLogger(for: .scheduling)
        )
        let useCase = TodayReflectionUseCase(
            repository: repository,
            returnScheduler: scheduler,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
            uuidGenerator: .fixed(UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 2))),
            logger: loggerFactory.makeLogger(for: .featureReflection)
        )

        return TodayReflectionModel(
            useCase: useCase,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
            logger: loggerFactory.makeLogger(for: .featureToday),
            items: items,
            loadState: items.isEmpty ? .empty : .loaded
        )
    }
}
