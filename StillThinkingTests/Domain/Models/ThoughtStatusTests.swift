//
//  ThoughtStatusTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Testing
@testable import StillThinking

@Suite("Статусы мысли")
struct ThoughtStatusTests {
    @Test("Ожидающая мысль может вернуться")
    func pendingThoughtCanReturn() throws {
        let thought = makeThought(status: .pending)
        let returned = try thought.transitioning(to: .returned, at: Date(timeIntervalSinceReferenceDate: 10))

        #expect(returned.status == .returned)
        #expect(returned.updatedAt == Date(timeIntervalSinceReferenceDate: 10))
    }

    @Test("Вернувшуюся мысль можно завершить")
    func returnedThoughtCanComplete() throws {
        let thought = makeThought(status: .returned)
        let completed = try thought.transitioning(to: .completed, at: Date(timeIntervalSinceReferenceDate: 20))

        #expect(completed.status == .completed)
        #expect(completed.updatedAt == Date(timeIntervalSinceReferenceDate: 20))
    }

    @Test("Завершённая мысль не возвращается в работу")
    func completedThoughtCannotReturnToPending() {
        let thought = makeThought(status: .completed)

        #expect(throws: ThoughtTransitionError.invalidTransition(from: .completed, to: .pending)) {
            _ = try thought.transitioning(to: .pending, at: Date(timeIntervalSinceReferenceDate: 30))
        }
    }

    @Test("Отпущенная мысль является терминальным состоянием")
    func releasedThoughtIsTerminal() {
        #expect(ThoughtStatus.released.isTerminal)
        #expect(ThoughtStatus.released.canTransition(to: .returned) == false)
    }

    private func makeThought(status: ThoughtStatus) -> Thought {
        Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1)),
            text: "Текст мысли",
            status: status,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )
    }
}
