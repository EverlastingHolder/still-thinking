//
//  LogChannel.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

enum LogChannel: String, CaseIterable, Sendable {
    case app
    case database
    case notifications
    case authentication
    case scheduling
    case navigation
    case featureThoughtCapture = "feature.thoughtCapture"
    case featureToday = "feature.today"
    case featureReflection = "feature.reflection"
    case featureTimeline = "feature.timeline"
    case featureArchive = "feature.archive"
    case featureSettings = "feature.settings"
}
