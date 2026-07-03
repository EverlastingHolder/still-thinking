//
//  LogConfigurationParser.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

struct LogConfigurationParser {
    static func configuration(
        arguments: [String],
        environment: [String: String],
        defaultConfiguration: LogConfiguration
    ) -> LogConfiguration {
        let environmentConfiguration = applyEnvironment(environment, to: defaultConfiguration)
        return applyArguments(arguments, to: environmentConfiguration)
    }

    private static func applyEnvironment(
        _ environment: [String: String],
        to configuration: LogConfiguration
    ) -> LogConfiguration {
        let enabledChannels = channels(
            from: environment["ST_LOG_CHANNELS"],
            fallback: configuration.enabledChannels,
            allValue: environment["ST_LOG_ALL"],
            noneValue: environment["ST_LOG_NONE"]
        )
        let minimumLevel = level(from: environment["ST_LOG_LEVEL"]) ?? configuration.minimumLevel

        return LogConfiguration(enabledChannels: enabledChannels, minimumLevel: minimumLevel)
    }

    private static func applyArguments(_ arguments: [String], to configuration: LogConfiguration) -> LogConfiguration {
        let values = argumentValues(arguments)
        let enabledChannels = channels(
            from: values["-STLogChannels"],
            fallback: configuration.enabledChannels,
            allValue: values["-STLogAll"],
            noneValue: values["-STLogNone"]
        )
        let minimumLevel = level(from: values["-STLogLevel"]) ?? configuration.minimumLevel

        return LogConfiguration(enabledChannels: enabledChannels, minimumLevel: minimumLevel)
    }

    private static func argumentValues(_ arguments: [String]) -> [String: String] {
        var values: [String: String] = [:]
        var index = arguments.startIndex

        while index < arguments.endIndex {
            let key = arguments[index]
            let valueIndex = arguments.index(after: index)

            if key.hasPrefix("-STLog"), valueIndex < arguments.endIndex {
                values[key] = arguments[valueIndex]
                index = arguments.index(after: valueIndex)
            } else {
                index = valueIndex
            }
        }

        return values
    }

    private static func channels(
        from value: String?,
        fallback: Set<LogChannel>,
        allValue: String?,
        noneValue: String?
    ) -> Set<LogChannel> {
        if isEnabled(noneValue) {
            return []
        }

        if isEnabled(allValue) {
            return Set(LogChannel.allCases)
        }

        guard let value else {
            return fallback
        }

        return Set(
            value
                .split(separator: ",")
                .compactMap { LogChannel(rawValue: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        )
    }

    private static func level(from value: String?) -> LogLevel? {
        value.flatMap(LogLevel.init(rawValue:))
    }

    private static func isEnabled(_ value: String?) -> Bool {
        switch value?.lowercased() {
        case "1", "true", "yes":
            true
        default:
            false
        }
    }
}
