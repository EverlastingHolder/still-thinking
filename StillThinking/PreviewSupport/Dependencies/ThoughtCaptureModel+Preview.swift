//
//  ThoughtCaptureModel+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

extension ThoughtCaptureModel {
    @MainActor
    static func preview(
        text: String = "",
        validationMessage: String? = nil,
        pendingThoughtCount: Int = 0
    ) -> ThoughtCaptureModel {
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

        return ThoughtCaptureModel(
            repository: repository,
            returnScheduler: scheduler,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
            uuidGenerator: .fixed(UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))),
            logger: loggerFactory.makeLogger(for: .featureThoughtCapture),
            text: text,
            validationMessage: validationMessage,
            pendingThoughtCount: pendingThoughtCount
        )
    }
}
