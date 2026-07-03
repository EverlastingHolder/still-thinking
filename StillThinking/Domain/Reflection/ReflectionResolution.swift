//
//  ReflectionResolution.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

enum ReflectionResolution: Equatable, Sendable {
    case complete
    case release
    case reschedule(Date)
}
