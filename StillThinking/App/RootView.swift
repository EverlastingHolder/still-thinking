//
//  RootView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

struct RootView: View {
    let environment: AppEnvironment

    var body: some View {
        Text("Still Thinking")
            .onAppear {
                environment.loggerFactory
                    .makeLogger(for: .app)
                    .info("Root view appeared")
            }
    }
}

#Preview {
    AppCompositionRoot.makeRootView(environment: .preview)
}
