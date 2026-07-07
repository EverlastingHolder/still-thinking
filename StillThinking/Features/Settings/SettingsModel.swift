//
//  SettingsModel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsModel {
    var settings: AppSettings
    var deletionMessage: String?
    var isDeletingAllData: Bool
    var exportFileURL: URL?
    var exportMessage: String?
    var isExportingData: Bool
    var scheduleUpdateMessage: String?

    private let settingsStore: AppSettingsStore
    private let repository: any ThoughtRepository
    private let returnScheduler: ReturnScheduler
    private let localDataExporter: LocalDataExportUseCase
    private let exportDirectory: URL
    private let logger: LoggerClient

    init(
        settingsStore: AppSettingsStore,
        repository: any ThoughtRepository,
        returnScheduler: ReturnScheduler,
        localDataExporter: LocalDataExportUseCase? = nil,
        exportDirectory: URL = FileManager.default.temporaryDirectory,
        logger: LoggerClient,
        deletionMessage: String? = nil,
        isDeletingAllData: Bool = false,
        exportFileURL: URL? = nil,
        exportMessage: String? = nil,
        isExportingData: Bool = false,
        scheduleUpdateMessage: String? = nil
    ) {
        self.settingsStore = settingsStore
        self.repository = repository
        self.returnScheduler = returnScheduler
        self.localDataExporter = localDataExporter ?? LocalDataExportUseCase(
            repository: repository,
            settingsStore: settingsStore,
            clock: .live
        )
        self.exportDirectory = exportDirectory
        self.logger = logger
        self.settings = settingsStore.settings
        self.deletionMessage = deletionMessage
        self.isDeletingAllData = isDeletingAllData
        self.exportFileURL = exportFileURL
        self.exportMessage = exportMessage
        self.isExportingData = isExportingData
        self.scheduleUpdateMessage = scheduleUpdateMessage
    }

    func setShowsThoughtTextInNotifications(_ isEnabled: Bool) async {
        settings.showsThoughtTextInNotifications = isEnabled
        await saveSettingsAndRebuildNotifications()
    }

    func setReturnsPaused(_ isPaused: Bool) async {
        settings.returnsPaused = isPaused
        await saveSettingsAndRebuildNotifications()
    }

    func setNotificationStartHour(_ hour: Int) async {
        settings.notificationStartHour = min(max(hour, 0), 23)
        if settings.notificationEndHour <= settings.notificationStartHour {
            settings.notificationEndHour = settings.notificationStartHour + 1
        }
        await saveSettingsAndRebuildNotifications()
    }

    func setNotificationEndHour(_ hour: Int) async {
        settings.notificationEndHour = min(max(hour, settings.notificationStartHour + 1), 24)
        await saveSettingsAndRebuildNotifications()
    }

    func refreshFromStore() {
        settings = settingsStore.settings
    }

    func deleteAllData() async {
        isDeletingAllData = true
        deletionMessage = nil

        do {
            try await repository.deleteAllData()
            deletionMessage = String(localized: "settings.delete.success")
            logger.info("All local data deleted")
        } catch {
            deletionMessage = String(localized: "settings.delete.failed")
            logger.error(
                "All local data deletion failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }

        isDeletingAllData = false
    }

    func prepareDataExport() async {
        isExportingData = true
        exportFileURL = nil
        exportMessage = nil

        do {
            let file = try await localDataExporter.makeFile()
            let url = exportDirectory.appendingPathComponent(file.filename)
            try file.data.write(to: url, options: [.atomic])
            exportFileURL = url
            exportMessage = String(localized: "settings.export.ready")
            logger.info("Local data export prepared", metadata: ["byteCount": String(file.data.count)])
        } catch {
            exportMessage = String(localized: "settings.export.failed")
            logger.error(
                "Local data export failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }

        isExportingData = false
    }

    private func saveSettingsAndRebuildNotifications() async {
        settingsStore.settings = settings
        scheduleUpdateMessage = nil

        do {
            try await returnScheduler.rebuildPendingNotifications()
        } catch {
            scheduleUpdateMessage = String(localized: "settings.notifications.rebuildFailed")
            logger.error(
                "Return notification rebuild failed",
                metadata: ["errorType": String(describing: type(of: error))]
            )
        }
    }
}
