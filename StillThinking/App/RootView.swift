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

    @MainActor
    init(environment: AppEnvironment) {
        self.environment = environment
        _thoughtCaptureModel = State(
            initialValue: AppCompositionRoot.makeThoughtCaptureModel(environment: environment)
        )
    }

    var body: some View {
        NavigationStack {
            ThoughtCaptureView(model: thoughtCaptureModel)
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
