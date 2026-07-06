//
//  LogLevel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum LogLevel: String, CaseIterable, Comparable, Identifiable, Sendable {
    case debug
    case info
    case notice
    case error
    case fault

    var id: String {
        rawValue
    }

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.priority < rhs.priority
    }

    private var priority: Int {
        switch self {
        case .debug:
            0
        case .info:
            1
        case .notice:
            2
        case .error:
            3
        case .fault:
            4
        }
    }
}
