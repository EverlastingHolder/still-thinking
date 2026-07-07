//
//  LocalDataExportUseCase.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Foundation

@MainActor
final class LocalDataExportUseCase {
    private let repository: any ThoughtRepository
    private let settingsStore: AppSettingsStore
    private let clock: ClockClient
    private let encoder: JSONEncoder

    init(
        repository: any ThoughtRepository,
        settingsStore: AppSettingsStore,
        clock: ClockClient,
        encoder: JSONEncoder = LocalDataExportUseCase.makeEncoder()
    ) {
        self.repository = repository
        self.settingsStore = settingsStore
        self.clock = clock
        self.encoder = encoder
    }

    func makeFile() async throws -> LocalDataExportFile {
        let exportedAt = clock.now()
        let snapshot = try await makeSnapshot(exportedAt: exportedAt)
        let data = try encoder.encode(snapshot)

        return LocalDataExportFile(
            filename: "still-thinking-export-\(Self.filenameDate(from: exportedAt)).json",
            data: data
        )
    }

    private func makeSnapshot(exportedAt: Date) async throws -> LocalDataExportSnapshot {
        var thoughts: [Thought] = []

        for status in ThoughtStatus.allCases {
            thoughts.append(contentsOf: try await repository.thoughts(with: status))
        }

        let exportedThoughts = try await thoughts
            .sorted { lhs, rhs in lhs.createdAt < rhs.createdAt }
            .asyncMap { thought in
                ExportedThought(
                    thought: thought,
                    reflections: try await repository.reflections(for: thought.id),
                    schedules: try await repository.schedules(for: thought.id)
                )
            }

        return LocalDataExportSnapshot(
            formatVersion: 1,
            exportedAt: exportedAt,
            settings: settingsStore.settings,
            thoughts: exportedThoughts
        )
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static func filenameDate(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
            .replacingOccurrences(of: ":", with: "-")
    }
}

struct LocalDataExportFile: Equatable, Sendable {
    let filename: String
    let data: Data
}

private extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async throws -> [T] {
        var values: [T] = []

        for element in self {
            let value = try await transform(element)
            values.append(value)
        }

        return values
    }
}
