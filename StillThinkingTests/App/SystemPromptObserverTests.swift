//
//  SystemPromptObserverTests.swift
//  StillThinkingTests
//
//  Created by roman.moshkovcev on 06.07.2026.
//

@testable import StillThinking
import Testing

@Suite("System prompt observer")
@MainActor
struct SystemPromptObserverTests {
    @Test("Помечает системный алерт активным во время операции")
    func marksPromptActiveWhileOperationRuns() async throws {
        let observer = SystemPromptObserver()

        let isActiveInsideOperation = await observer.track {
            observer.isPresentingSystemPrompt
        }

        #expect(isActiveInsideOperation)
        #expect(observer.isPresentingSystemPrompt == false)
    }

    @Test("Сбрасывает системный алерт после ошибки операции")
    func resetsPromptAfterOperationFailure() async {
        let observer = SystemPromptObserver()

        do {
            try await observer.track {
                throw TestError.expected
            }
        } catch {
            #expect(error as? TestError == .expected)
        }

        #expect(observer.isPresentingSystemPrompt == false)
    }
}

private enum TestError: Error {
    case expected
}
