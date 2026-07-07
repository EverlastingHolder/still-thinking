//
//  ThoughtTimelineModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ThoughtTimelineModel {
    let thoughtID: UUID
    var entries: [ThoughtTimelineEntry]
    var isLoading: Bool
    var isDeleted: Bool
    var errorMessage: String?

    private let useCase: ArchiveUseCase
    private let logger: LoggerClient

    init(
        thoughtID: UUID,
        useCase: ArchiveUseCase,
        logger: LoggerClient,
        entries: [ThoughtTimelineEntry] = [],
        isLoading: Bool = false,
        isDeleted: Bool = false,
        errorMessage: String? = nil
    ) {
        self.thoughtID = thoughtID
        self.useCase = useCase
        self.logger = logger
        self.entries = entries
        self.isLoading = isLoading
        self.isDeleted = isDeleted
        self.errorMessage = errorMessage
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            entries = try await useCase.loadTimeline(thoughtID: thoughtID)
        } catch {
            errorMessage = String(localized: "timeline.error.loadFailed")
            logger.error(
                "Timeline loading failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }

        isLoading = false
    }

    func deleteThought() async {
        do {
            try await useCase.deleteThought(id: thoughtID)
            entries = []
            isDeleted = true
        } catch {
            errorMessage = String(localized: "timeline.error.deleteFailed")
            logger.error(
                "Thought deletion failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }
}
