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
            Section("developerLogging.section.source") {
                LabeledContent("developerLogging.source.active", value: activeSource.title)
                Text("developerLogging.source.footer")
                    .foregroundStyle(.secondary)
            }

            Section("developerLogging.section.level") {
                Picker("developerLogging.minimumLevel.picker", selection: levelBinding) {
                    ForEach(LogLevel.allCases) { level in
                        Text(level.localized).tag(level)
                    }
                }
            }

            Section("developerLogging.section.channels") {
                ForEach(LogChannel.allCases, id: \.self) { channel in
                    Toggle(channel.localized, isOn: channelBinding(channel))
                }
            }

            Section {
                Button("developerLogging.enableAll.button") {
                    model.enableAll()
                }

                Button("developerLogging.disableAll.button") {
                    model.disableAll()
                }

                Button("developerLogging.reset.button") {
                    model.reset()
                }
            }
        }
        .navigationTitle("developerLogging.navigationTitle")
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
