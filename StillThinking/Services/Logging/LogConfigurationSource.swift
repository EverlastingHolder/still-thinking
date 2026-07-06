//
//  LogConfigurationSource.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

enum LogConfigurationSource: String, Equatable, Sendable {
    case launchArguments
    case environment
    case debugPreferences
    case projectDefault

    var title: String {
        switch self {
        case .launchArguments:
            "Launch arguments"
        case .environment:
            "Environment"
        case .debugPreferences:
            "Developer Logging"
        case .projectDefault:
            "Project default"
        }
    }
}
