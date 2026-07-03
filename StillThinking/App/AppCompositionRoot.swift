//
//  AppCompositionRoot.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

enum AppCompositionRoot {
    @MainActor
    static func makeRootView(environment: AppEnvironment) -> RootView {
        RootView(environment: environment)
    }

    @MainActor
    static func makeThoughtCaptureModel(environment: AppEnvironment) -> ThoughtCaptureModel {
        ThoughtCaptureModel(
            repository: environment.thoughtRepository,
            returnScheduler: environment.returnScheduler,
            clock: environment.clock,
            uuidGenerator: environment.uuidGenerator,
            logger: environment.loggerFactory.makeLogger(for: .featureThoughtCapture)
        )
    }

    @MainActor
    static func makeTodayReflectionModel(environment: AppEnvironment) -> TodayReflectionModel {
        let useCase = TodayReflectionUseCase(
            repository: environment.thoughtRepository,
            returnScheduler: environment.returnScheduler,
            clock: environment.clock,
            uuidGenerator: environment.uuidGenerator,
            logger: environment.loggerFactory.makeLogger(for: .featureReflection)
        )

        return TodayReflectionModel(
            useCase: useCase,
            clock: environment.clock,
            logger: environment.loggerFactory.makeLogger(for: .featureToday)
        )
    }

    @MainActor
    static func makeArchiveModel(environment: AppEnvironment) -> ArchiveModel {
        ArchiveModel(
            useCase: makeArchiveUseCase(environment: environment),
            logger: environment.loggerFactory.makeLogger(for: .featureArchive)
        )
    }

    @MainActor
    static func makeThoughtTimelineModel(
        thoughtID: UUID,
        environment: AppEnvironment
    ) -> ThoughtTimelineModel {
        ThoughtTimelineModel(
            thoughtID: thoughtID,
            useCase: makeArchiveUseCase(environment: environment),
            logger: environment.loggerFactory.makeLogger(for: .featureArchive)
        )
    }

    @MainActor
    private static func makeArchiveUseCase(environment: AppEnvironment) -> ArchiveUseCase {
        ArchiveUseCase(
            repository: environment.thoughtRepository,
            logger: environment.loggerFactory.makeLogger(for: .featureArchive)
        )
    }
}
