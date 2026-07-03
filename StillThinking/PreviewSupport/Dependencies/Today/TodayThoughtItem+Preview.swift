//
//  TodayThoughtItem+Preview.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

extension TodayThoughtItem {
    static func preview(
        text: String = "Вернуться к решению о том, какой вариант кажется честнее через несколько дней."
    ) -> TodayThoughtItem {
        TodayThoughtItem(
            thought: Thought(
                id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 1)),
                text: text,
                status: .returned,
                createdAt: Date(timeIntervalSinceReferenceDate: 0),
                updatedAt: Date(timeIntervalSinceReferenceDate: 86_400)
            ),
            returnedAt: Date(timeIntervalSinceReferenceDate: 86_400),
            reflectionCount: 0
        )
    }
}
