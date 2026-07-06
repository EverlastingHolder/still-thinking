//
//  ThoughtCaptureModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ThoughtCaptureModel {
    var text: String
    var selectedPreset: ThoughtReturnPreset
    var customReturnDate: Date
    var validationMessage: String?
    var saveState: ThoughtCaptureSaveState
    var pendingThoughtCount: Int

    private let repository: any ThoughtRepository
    private let returnScheduler: ReturnScheduler?
    private let clock: ClockClient
    private let uuidGenerator: UUIDGenerator
    private let logger: LoggerClient

    init(
        repository: any ThoughtRepository,
        returnScheduler: ReturnScheduler? = nil,
        clock: ClockClient,
        uuidGenerator: UUIDGenerator,
        logger: LoggerClient,
        text: String = "",
        selectedPreset: ThoughtReturnPreset = .tomorrow,
        customReturnDate: Date? = nil,
        validationMessage: String? = nil,
        saveState: ThoughtCaptureSaveState = .idle,
        pendingThoughtCount: Int = 0
    ) {
        self.repository = repository
        self.returnScheduler = returnScheduler
        self.clock = clock
        self.uuidGenerator = uuidGenerator
        self.logger = logger
        self.text = text
        self.selectedPreset = selectedPreset
        self.customReturnDate = customReturnDate ?? clock.now().addingTimeInterval(60)
        self.validationMessage = validationMessage
        self.saveState = saveState
        self.pendingThoughtCount = pendingThoughtCount
    }

    var isSaving: Bool {
        saveState == .saving
    }

    var canSave: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && isSaving == false
    }

    var minimumCustomReturnDate: Date {
        clock.now().addingTimeInterval(60)
    }

    func loadPendingThoughtCount() async {
        do {
            pendingThoughtCount = try await repository.thoughts(with: .pending).count
        } catch {
            logger.error(
                "Pending thought count loading failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    func save() async {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false else {
            validationMessage = "Введите мысль, которую хотите вернуть позже."
            saveState = .idle
            return
        }

        let now = clock.now()
        let dueDate = selectedPreset.dueDate(from: now, customDate: customReturnDate)

        guard dueDate >= minimumCustomReturnDate else {
            validationMessage = "Выберите дату в будущем."
            saveState = .idle
            return
        }

        saveState = .saving
        validationMessage = nil

        do {
            let thoughtID = uuidGenerator.make()
            let thought = Thought(
                id: thoughtID,
                text: trimmedText,
                status: .pending,
                createdAt: now,
                updatedAt: now
            )
            let schedule = ReturnSchedule(
                id: uuidGenerator.make(),
                thoughtID: thoughtID,
                dueAt: dueDate,
                state: .scheduled,
                notificationIdentifier: nil,
                createdAt: now,
                updatedAt: now
            )

            try await repository.createThought(thought, schedule: schedule)
            await scheduleReturn(schedule)
            text = ""
            customReturnDate = minimumCustomReturnDate
            saveState = .saved
            await loadPendingThoughtCount()
        } catch {
            saveState = .failed
            validationMessage = "Не удалось сохранить мысль. Попробуйте ещё раз."
            logger.error(
                "Thought creation failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    private func scheduleReturn(_ schedule: ReturnSchedule) async {
        do {
            try await returnScheduler?.schedule(schedule)
        } catch {
            logger.error(
                "Return scheduling failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }
}
