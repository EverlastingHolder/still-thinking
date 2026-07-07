//
//  AppSettingsTests.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 07.07.2026.
//

import Foundation
import Testing
@testable import StillThinking

@Suite("Настройки приложения")
struct AppSettingsTests {
    @Test("Окно уведомлений учитывает часовой пояс календаря")
    func notificationDateUsesCalendarTimeZone() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 7 * 60 * 60))
        var settings = AppSettings.default
        settings.notificationStartHour = 9
        settings.notificationEndHour = 21

        let dueAt = Date(timeIntervalSince1970: 1_704_031_200)
        let notificationDate = settings.notificationDate(for: dueAt, calendar: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)

        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 1)
        #expect(components.hour == 9)
        #expect(components.minute == 0)
    }

    @Test("Позднее уведомление переносится на начало следующего локального дня")
    func lateNotificationMovesToNextLocalDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        var settings = AppSettings.default
        settings.notificationStartHour = 9
        settings.notificationEndHour = 21

        let dueAt = Date(timeIntervalSince1970: 1_704_150_000)
        let notificationDate = settings.notificationDate(for: dueAt, calendar: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)

        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 2)
        #expect(components.hour == 9)
        #expect(components.minute == 0)
    }
}
