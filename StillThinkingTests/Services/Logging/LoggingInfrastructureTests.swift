//
//  LoggingInfrastructureTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation
import Testing
@testable import StillThinking

@Suite("Инфраструктура логирования")
struct LoggingInfrastructureTests {
    @Test("Включённый канал передаёт событие в sink")
    func enabledChannelWritesEvent() {
        let recorder = RecordingLogSink()
        let logger = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.database], minimumLevel: .debug),
            sink: recorder
        ).makeLogger(for: .database)

        logger.info("Database opened", metadata: ["operation": "open"])

        #expect(recorder.events == [
            LogEvent(
                channel: .database,
                level: .info,
                message: "Database opened",
                metadata: ["operation": "open"]
            )
        ])
    }

    @Test("Отключённый канал не вычисляет сообщение и metadata")
    func disabledChannelSkipsMessageAndMetadata() {
        let recorder = RecordingLogSink()
        let logger = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.app], minimumLevel: .debug),
            sink: recorder
        ).makeLogger(for: .database)
        var messageEvaluated = false
        var metadataEvaluated = false

        logger.debug(message(&messageEvaluated), metadata: metadata(&metadataEvaluated))

        #expect(recorder.events.isEmpty)
        #expect(messageEvaluated == false)
        #expect(metadataEvaluated == false)
    }

    @Test("Минимальный уровень фильтрует менее важные события")
    func minimumLevelFiltersLowPriorityEvents() {
        let recorder = RecordingLogSink()
        let logger = LoggerFactory(
            configuration: LogConfiguration(enabledChannels: [.app], minimumLevel: .notice),
            sink: recorder
        ).makeLogger(for: .app)

        logger.info("Hidden")
        logger.error("Visible")

        #expect(recorder.events.map(\.level) == [.error])
    }

    @Test("Launch arguments имеют приоритет над environment")
    func launchArgumentsOverrideEnvironment() {
        let configuration = LogConfigurationParser.configuration(
            arguments: ["app", "-STLogChannels", "database", "-STLogLevel", "debug"],
            environment: ["ST_LOG_CHANNELS": "notifications", "ST_LOG_LEVEL": "error"],
            defaultConfiguration: .debugDefault
        )

        #expect(configuration.enabledChannels == [.database])
        #expect(configuration.minimumLevel == .debug)
    }

    @Test("STLogAll включает все зарегистрированные каналы")
    func logAllEnablesEveryChannel() {
        let configuration = LogConfigurationParser.configuration(
            arguments: ["app", "-STLogAll", "YES"],
            environment: [:],
            defaultConfiguration: .debugDefault
        )

        #expect(configuration.enabledChannels == Set(LogChannel.allCases))
    }

    @Test("STLogNone отключает все каналы")
    func logNoneDisablesEveryChannel() {
        let configuration = LogConfigurationParser.configuration(
            arguments: ["app", "-STLogNone", "YES"],
            environment: ["ST_LOG_ALL": "1"],
            defaultConfiguration: .debugDefault
        )

        #expect(configuration.enabledChannels.isEmpty)
    }

    @Test("Неизвестные каналы игнорируются без crash")
    func unknownChannelsAreIgnored() {
        let configuration = LogConfigurationParser.configuration(
            arguments: ["app", "-STLogChannels", "database,unknown,feature.today"],
            environment: [:],
            defaultConfiguration: .debugDefault
        )

        #expect(configuration.enabledChannels == [.database, .featureToday])
    }

    @Test("Release policy не разрешает debug события")
    func releasePolicyFiltersDebugEvents() {
        let recorder = RecordingLogSink()
        let logger = LoggerFactory(
            configuration: .releaseDefault,
            sink: recorder
        ).makeLogger(for: .app)

        logger.debug("Hidden")
        logger.error("Visible")

        #expect(recorder.events.map(\.level) == [.error])
    }

    @Test("Preview environment использует fixed зависимости и no-op logger")
    @MainActor
    func previewEnvironmentUsesDeterministicDependencies() {
        let environment = AppEnvironment.preview()
        let logger = environment.loggerFactory.makeLogger(for: .app)

        logger.fault("Hidden")

        #expect(environment.clock.now() == Date(timeIntervalSinceReferenceDate: 0))
        #expect(environment.uuidGenerator.make().uuidString == "00000000-0000-0000-0000-000000000001")
    }

    private func message(_ evaluated: inout Bool) -> String {
        evaluated = true
        return "Hidden"
    }

    private func metadata(_ evaluated: inout Bool) -> [String: String] {
        evaluated = true
        return ["operation": "hidden"]
    }
}
