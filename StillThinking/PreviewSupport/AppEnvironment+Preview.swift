//
//  AppEnvironment+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

extension AppEnvironment {
    static let preview = AppEnvironment(
        clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
        uuidGenerator: .fixed(UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))),
        loggerFactory: LoggerFactory(
            configuration: .disabled,
            sink: NoOpLogSink()
        )
    )
}
