//
//  PreviewModelContainerFactory.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftData

enum PreviewModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        do {
            return try StillThinkingModelContainerFactory.inMemory()
        } catch {
            preconditionFailure("Preview ModelContainer creation failed: \(error)")
        }
    }
}
