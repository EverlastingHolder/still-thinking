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
}
