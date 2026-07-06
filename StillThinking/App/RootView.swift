//
//  RootView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct RootView: View {
    let environment: AppEnvironment
    @State private var thoughtCaptureModel: ThoughtCaptureModel
    @State private var todayReflectionModel: TodayReflectionModel
    @State private var archiveModel: ArchiveModel
    @State private var settingsModel: SettingsModel
    @State private var privacyLockModel: PrivacyLockModel
    @Environment(\.scenePhase)
    private var scenePhase

    @MainActor
    init(environment: AppEnvironment) {
        self.environment = environment
        _thoughtCaptureModel = State(
            initialValue: AppCompositionRoot.makeThoughtCaptureModel(environment: environment)
        )
        _todayReflectionModel = State(
            initialValue: AppCompositionRoot.makeTodayReflectionModel(environment: environment)
        )
        _archiveModel = State(
            initialValue: AppCompositionRoot.makeArchiveModel(environment: environment)
        )
        _settingsModel = State(
            initialValue: AppCompositionRoot.makeSettingsModel(environment: environment)
        )
        _privacyLockModel = State(
            initialValue: AppCompositionRoot.makePrivacyLockModel(environment: environment)
        )
    }

    var body: some View {
        TabView {
            NavigationStack {
                ThoughtCaptureView(model: thoughtCaptureModel)
            }
            .tabItem {
                Label("Запись", systemImage: "square.and.pencil")
            }

            NavigationStack {
                TodayReflectionView(model: todayReflectionModel)
            }
            .tabItem {
                Label("Сегодня", systemImage: "calendar")
            }

            NavigationStack {
                ArchiveView(
                    model: archiveModel,
                    makeTimelineModel: { thoughtID in
                        AppCompositionRoot.makeThoughtTimelineModel(
                            thoughtID: thoughtID,
                            environment: environment
                        )
                    }
                )
            }
            .tabItem {
                Label("Архив", systemImage: "archivebox")
            }

            NavigationStack {
                SettingsView(
                    model: settingsModel,
                    privacyLockModel: privacyLockModel,
                    logConfigurationSource: environment.logConfigurationSource,
                    makeDeveloperLoggingModel: {
                        AppCompositionRoot.makeDeveloperLoggingModel(environment: environment)
                    }
                )
            }
            .tabItem {
                Label("Настройки", systemImage: "gearshape")
            }
        }
        .overlay {
            if privacyLockModel.state == .locked || privacyLockModel.state == .failed {
                PrivacyShieldView(model: privacyLockModel)
            }
        }
        .onAppear {
            environment.loggerFactory
                .makeLogger(for: .app)
                .info("Root view appeared")
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                privacyLockModel.lockIfNeeded()
            }
        }
    }
}

#Preview {
    AppCompositionRoot.makeRootView(environment: .preview())
}
