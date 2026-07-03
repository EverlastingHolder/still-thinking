//
//  ThoughtCaptureModelTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import SwiftData
import Testing
@testable import StillThinking

@MainActor
@Suite("Модель создания мысли")
struct ThoughtCaptureModelTests {
    @Test("Пустая мысль не сохраняется")
    func emptyThoughtDoesNotSave() async throws {
        let model = try makeModel(text: "   ")

        await model.save()

        #expect(model.validationMessage == "Введите мысль, которую хотите вернуть позже.")
        #expect(model.saveState == .idle)
        #expect(model.pendingThoughtCount == 0)
    }

    @Test("Корректная мысль сохраняется с расписанием")
    func validThoughtSavesWithSchedule() async throws {
        let fixture = try makeFixture(text: "Вернуться к идее")

        await fixture.model.save()

        let thoughts = try await fixture.repository.thoughts(with: .pending)
        let thought = try #require(thoughts.first)
        let schedules = try await fixture.repository.schedules(for: thought.id)
        let schedule = try #require(schedules.first)

        #expect(thought.text == "Вернуться к идее")
        #expect(schedule.dueAt == Date(timeIntervalSinceReferenceDate: 86_400))
        #expect(fixture.model.text.isEmpty)
        #expect(fixture.model.pendingThoughtCount == 1)
        #expect(fixture.model.saveState == .saved)
    }

    @Test("Пользовательская дата в прошлом отклоняется")
    func pastCustomDateIsRejected() async throws {
        let model = try makeModel(
            text: "Вернуться к идее",
            selectedPreset: .custom,
            customReturnDate: Date(timeIntervalSinceReferenceDate: -10)
        )

        await model.save()

        #expect(model.validationMessage == "Выберите дату в будущем.")
        #expect(model.pendingThoughtCount == 0)
    }

    @Test("Счётчик ожидающих мыслей загружается из repository")
    func pendingCountLoadsFromRepository() async throws {
        let fixture = try makeFixture(text: "")
        let thought = Thought(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 1)),
            text: "Сохранённая мысль",
            status: .pending,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )

        try await fixture.repository.createThought(thought, schedule: nil)
        await fixture.model.loadPendingThoughtCount()

        #expect(fixture.model.pendingThoughtCount == 1)
    }

    private func makeModel(
        text: String,
        selectedPreset: ThoughtReturnPreset = .tomorrow,
        customReturnDate: Date? = nil
    ) throws -> ThoughtCaptureModel {
        try makeFixture(
            text: text,
            selectedPreset: selectedPreset,
            customReturnDate: customReturnDate
        ).model
    }

    private func makeFixture(
        text: String,
        selectedPreset: ThoughtReturnPreset = .tomorrow,
        customReturnDate: Date? = nil
    ) throws -> Fixture {
        let container = try StillThinkingModelContainerFactory.inMemory()
        let recorder = RecordingLogSink()
        let loggerFactory = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.database, .featureThoughtCapture], minimumLevel: .debug),
            sink: recorder
        )
        let repository = SwiftDataThoughtRepository(
            context: ModelContext(container),
            logger: loggerFactory.makeLogger(for: .database)
        )
        let model = ThoughtCaptureModel(
            repository: repository,
            clock: .fixed(Date(timeIntervalSinceReferenceDate: 0)),
            uuidGenerator: .fixed(UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 2))),
            logger: loggerFactory.makeLogger(for: .featureThoughtCapture),
            text: text,
            selectedPreset: selectedPreset,
            customReturnDate: customReturnDate
        )

        return Fixture(model: model, repository: repository)
    }

    private struct Fixture {
        let model: ThoughtCaptureModel
        let repository: SwiftDataThoughtRepository
    }
}
