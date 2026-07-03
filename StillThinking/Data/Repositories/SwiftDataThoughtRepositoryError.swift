//
//  SwiftDataThoughtRepositoryError.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

enum SwiftDataThoughtRepositoryError: Error, Equatable, Sendable {
    case thoughtNotFound(UUID)
}
