//
//  ThoughtReturnPreset.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

enum ThoughtReturnPreset: String, CaseIterable, Identifiable, Sendable {
    case tomorrow
    case week
    case month
    case custom

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .tomorrow:
            "Завтра"
        case .week:
            "Неделя"
        case .month:
            "Месяц"
        case .custom:
            "Дата"
        }
    }

    func dueDate(from date: Date, customDate: Date) -> Date {
        switch self {
        case .tomorrow:
            date.addingTimeInterval(86_400)
        case .week:
            date.addingTimeInterval(604_800)
        case .month:
            date.addingTimeInterval(2_592_000)
        case .custom:
            customDate
        }
    }
}
