//
//  UUIDGenerator.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct UUIDGenerator {
    let make: @Sendable () -> UUID

    static let live = UUIDGenerator(make: UUID.init)

    static func fixed(_ uuid: UUID) -> UUIDGenerator {
        UUIDGenerator { uuid }
    }
}
