//
//  AppEnvironment+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData

extension AppEnvironment {
    @MainActor
    static func preview() -> AppEnvironment {
        let loggerFactory = LoggerFactory(
            configuration: .disabled,
            sink: NoOpLogSink()
        )
        let container = PreviewModelContainerFactory.makeContainer()

        return AppEnvironment(
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
            uuidGenerator: .fixed(UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))),
            loggerFactory: loggerFactory,
            thoughtRepository: SwiftDataThoughtRepository(
                context: ModelContext(container),
                logger: loggerFactory.makeLogger(for: .database)
            )
        )
    }
}
