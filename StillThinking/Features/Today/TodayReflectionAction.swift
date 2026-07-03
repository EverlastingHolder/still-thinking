//
//  TodayReflectionAction.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

enum TodayReflectionAction: String, CaseIterable, Identifiable, Sendable {
    case complete
    case release
    case reschedule

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .complete:
            "Завершить"
        case .release:
            "Отпустить"
        case .reschedule:
            "Отложить"
        }
    }
}
