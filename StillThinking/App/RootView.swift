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

    @MainActor
    init(environment: AppEnvironment) {
        self.environment = environment
        _thoughtCaptureModel = State(
            initialValue: AppCompositionRoot.makeThoughtCaptureModel(environment: environment)
        )
        _todayReflectionModel = State(
            initialValue: AppCompositionRoot.makeTodayReflectionModel(environment: environment)
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
        }
            .onAppear {
                environment.loggerFactory
                    .makeLogger(for: .app)
                    .info("Root view appeared")
            }
    }
}

#Preview {
    AppCompositionRoot.makeRootView(environment: .preview())
}
