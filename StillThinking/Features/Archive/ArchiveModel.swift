//
//  ArchiveModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ArchiveModel {
    var items: [ArchiveThoughtItem]
    var selectedFilter: ArchiveStatusFilter
    var searchText: String
    var isLoading: Bool
    var errorMessage: String?
    var currentTime: Date = .now

    private let useCase: ArchiveUseCase
    private let logger: LoggerClient

    init(
        useCase: ArchiveUseCase,
        logger: LoggerClient,
        items: [ArchiveThoughtItem] = [],
        selectedFilter: ArchiveStatusFilter = .all,
        searchText: String = "",
        isLoading: Bool = false,
        errorMessage: String? = nil
    ) {
        self.useCase = useCase
        self.logger = logger
        self.items = items
        self.selectedFilter = selectedFilter
        self.searchText = searchText
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }

    var isEmptySearchResult: Bool {
        items.isEmpty && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await useCase.loadArchive(filter: selectedFilter, searchText: searchText)
        } catch {
            errorMessage = String(localized: "archive.error.loadFailed")
            logger.error(
                "Archive loading failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }

        isLoading = false
    }
}
