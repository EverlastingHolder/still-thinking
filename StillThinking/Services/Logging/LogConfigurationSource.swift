//
//  LogConfigurationSource.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

import Foundation

enum LogConfigurationSource: String, Equatable, Sendable {
    case launchArguments
    case environment
    case debugPreferences
    case projectDefault

    var title: String {
        switch self {
        case .launchArguments:
            String(localized: "developerLogging.source.launchArguments")
        case .environment:
            String(localized: "developerLogging.source.environment")
        case .debugPreferences:
            String(localized: "developerLogging.source.debugPreferences")
        case .projectDefault:
            String(localized: "developerLogging.source.projectDefault")
        }
    }
}
