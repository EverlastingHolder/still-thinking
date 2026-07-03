//
//  ThoughtCaptureSaveState.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum ThoughtCaptureSaveState: Equatable, Sendable {
    case idle
    case saving
    case saved
    case failed
}
