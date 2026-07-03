//
//  StillThinkingApp.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI

@main
struct StillThinkingApp: App {
    private let environment = AppEnvironment.production()

    var body: some Scene {
        WindowGroup {
            AppCompositionRoot.makeRootView(environment: environment)
        }
    }
}
