//
//  DeveloperLoggingView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 06.07.2026.
//

#if DEBUG
import SwiftUI

struct DeveloperLoggingView: View {
    @Bindable var model: DeveloperLoggingModel
    let activeSource: LogConfigurationSource

    var body: some View {
        Form {
            Section("Источник") {
                LabeledContent("Активен", value: activeSource.title)
                Text(
                    "Сохранённые настройки применятся после перезапуска приложения, " +
                        "если launch arguments или environment не задают логирование."
                )
                    .foregroundStyle(.secondary)
            }

            Section("Уровень") {
                Picker("Minimum level", selection: levelBinding) {
                    ForEach(LogLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
            }

            Section("Каналы") {
                ForEach(LogChannel.allCases, id: \.self) { channel in
                    Toggle(channel.rawValue, isOn: channelBinding(channel))
                }
            }

            Section {
                Button("Включить все") {
                    model.enableAll()
                }

                Button("Отключить все") {
                    model.disableAll()
                }

                Button("Сбросить") {
                    model.reset()
                }
            }
        }
        .navigationTitle("Logging")
    }

    private var levelBinding: Binding<LogLevel> {
        Binding {
            model.configuration.minimumLevel
        } set: { value in
            model.setMinimumLevel(value)
        }
    }

    private func channelBinding(_ channel: LogChannel) -> Binding<Bool> {
        Binding {
            model.configuration.enabledChannels.contains(channel)
        } set: { value in
            model.setChannel(channel, isEnabled: value)
        }
    }
}

#Preview {
    NavigationStack {
        DeveloperLoggingView(model: .preview(), activeSource: .projectDefault)
    }
}
#endif
