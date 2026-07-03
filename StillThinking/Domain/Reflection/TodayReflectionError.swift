//
//  TodayReflectionError.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

enum TodayReflectionError: Error, Equatable, Sendable {
    case thoughtNotFound(UUID)
    case thoughtIsNotReturned(UUID)
    case invalidReflectionText
}
