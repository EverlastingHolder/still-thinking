//
//  SystemPromptObserver.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Observation

@MainActor
@Observable
final class SystemPromptObserver {
    private(set) var activePromptCount = 0

    var isPresentingSystemPrompt: Bool {
        activePromptCount > 0
    }

    func track<T>(_ operation: () async throws -> T) async rethrows -> T {
        activePromptCount += 1
        defer {
            activePromptCount -= 1
        }

        return try await operation()
    }
}
