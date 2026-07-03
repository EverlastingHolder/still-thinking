//
//  TodayLoadState.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum TodayLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case empty
    case failed
}
