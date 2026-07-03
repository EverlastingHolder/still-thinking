//
//  TodayReflectionModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TodayReflectionModel {
    var items: [TodayThoughtItem]
    var reflectionText: String
    var selectedOpinionState: OpinionState
    var selectedAction: TodayReflectionAction
    var customReturnDate: Date
    var loadState: TodayLoadState
    var isSaving: Bool
    var validationMessage: String?

    private let useCase: TodayReflectionUseCase
    private let clock: ClockClient
    private let logger: LoggerClient

    init(
        useCase: TodayReflectionUseCase,
        clock: ClockClient,
        logger: LoggerClient,
        items: [TodayThoughtItem] = [],
        reflectionText: String = "",
        selectedOpinionState: OpinionState = .unchanged,
        selectedAction: TodayReflectionAction = .complete,
        customReturnDate: Date? = nil,
        loadState: TodayLoadState = .idle,
        isSaving: Bool = false,
        validationMessage: String? = nil
    ) {
        let now = clock.now()

        self.useCase = useCase
        self.clock = clock
        self.logger = logger
        self.items = items
        self.reflectionText = reflectionText
        self.selectedOpinionState = selectedOpinionState
        self.selectedAction = selectedAction
        self.customReturnDate = customReturnDate ?? now.addingTimeInterval(86_400)
        self.loadState = loadState
        self.isSaving = isSaving
        self.validationMessage = validationMessage
    }

    var currentItem: TodayThoughtItem? {
        items.first
    }

    var minimumCustomReturnDate: Date {
        clock.now().addingTimeInterval(60)
    }

    func load() async {
        loadState = .loading

        do {
            items = try await useCase.loadReturnedItems()
            loadState = items.isEmpty ? .empty : .loaded
        } catch {
            loadState = .failed
            logger.error(
                "Today loading failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }

    func applyPrompt(_ prompt: String) {
        if reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            reflectionText = prompt
        } else {
            reflectionText += "\n\n\(prompt)"
        }
    }

    func submitCurrentReflection() async {
        guard let currentItem else {
            validationMessage = "Сегодня нет мыслей для ответа."
            return
        }

        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false else {
            validationMessage = "Добавьте ответ перед сохранением."
            return
        }

        let resolution: ReflectionResolution
        switch selectedAction {
        case .complete:
            resolution = .complete
        case .release:
            resolution = .release
        case .reschedule:
            guard customReturnDate >= minimumCustomReturnDate else {
                validationMessage = "Выберите дату в будущем."
                return
            }

            resolution = .reschedule(customReturnDate)
        }

        isSaving = true
        validationMessage = nil

        do {
            try await useCase.submitReflection(
                thoughtID: currentItem.thought.id,
                text: trimmedText,
                opinionState: selectedOpinionState,
                resolution: resolution
            )
            resetForm()
            await load()
        } catch TodayReflectionError.invalidReflectionText {
            validationMessage = "Добавьте ответ перед сохранением."
        } catch {
            validationMessage = "Не удалось сохранить ответ. Попробуйте ещё раз."
            logger.error(
                "Reflection saving failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }

        isSaving = false
    }

    private func resetForm() {
        reflectionText = ""
        selectedOpinionState = .unchanged
        selectedAction = .complete
        customReturnDate = clock.now().addingTimeInterval(86_400)
    }
}
