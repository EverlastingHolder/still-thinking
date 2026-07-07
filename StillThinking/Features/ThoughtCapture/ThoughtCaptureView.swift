//
//  ThoughtCaptureView.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import SwiftUI
import UIKit

struct ThoughtCaptureView: View {
    @Bindable var model: ThoughtCaptureModel
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        Form {
            Section {
                ZStack(alignment: .topLeading) {
                    if model.text.isEmpty {
                        Text("thoughtCapture.placeholder")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $model.text)
                        .focused($isTextEditorFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .accessibilityLabel(Text("thoughtCapture.text.accessibilityLabel"))
                }
            } header: {
                Text("thoughtCapture.section.thought")
            } footer: {
                Text("thoughtCapture.section.thought.footer")
            }

            Section("thoughtCapture.section.return") {
                Picker("thoughtCapture.return.picker", selection: $model.selectedPreset) {
                    ForEach(ThoughtReturnPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .pickerStyle(.segmented)

                if model.selectedPreset == .custom {
                    DatePicker(
                        "thoughtCapture.customDate.label",
                        selection: $model.customReturnDate,
                        in: model.minimumCustomReturnDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            if let validationMessage = model.validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                        .accessibilityLabel(validationMessage)
                }
            }

            Section {
                Button {
                    Task {
                        await model.save()
                    }
                } label: {
                    if model.isSaving {
                        ProgressView()
                    } else {
                        Label("thoughtCapture.save.button", systemImage: "tray.and.arrow.down")
                    }
                }
                .disabled(model.canSave == false)

                if model.saveState == .saved {
                    Label("thoughtCapture.saved.label", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                }
            } footer: {
                unsafe Text(
                    String(
                        format: String(localized: "thoughtCapture.pendingCount"),
                        model.pendingThoughtCount
                    )
                )
            }
        }
        .navigationTitle("Still Thinking")
        .scrollDismissesKeyboard(.interactively)
        .background {
            KeyboardDismissTapLayer {
                isTextEditorFocused = false
            }
        }
        .task {
            await model.loadPendingThoughtCount()
        }
    }
}

private struct KeyboardDismissTapLayer: UIViewRepresentable {
    let onTap: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            context.coordinator.attach(to: view)
        }

        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.onTap = onTap
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onTap: () -> Void
        private weak var gestureRecognizer: UITapGestureRecognizer?

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        func attach(to view: UIView) {
            guard gestureRecognizer == nil else {
                return
            }

            guard let window = view.window else {
                DispatchQueue.main.async {
                    self.attach(to: view)
                }
                return
            }

            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            window.addGestureRecognizer(gestureRecognizer)
            self.gestureRecognizer = gestureRecognizer
        }

        @objc
        private func handleTap() {
            onTap()
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            var view = touch.view
            while let currentView = view {
                if currentView is UIControl || currentView is UITextView || currentView is UITextField {
                    return false
                }
                view = currentView.superview
            }

            return true
        }
    }
}

#Preview("Пусто") {
    NavigationStack {
        ThoughtCaptureView(model: .preview())
    }
}

#Preview("Длинный текст") {
    NavigationStack {
        ThoughtCaptureView(
            model: .preview(
                text: """
                Я продолжаю возвращаться к этой идее, потому что в ней есть несколько несвязанных пока частей:
                решение, сомнение и ощущение, что ответ появится позже.
                """,
                pendingThoughtCount: 3
            )
        )
    }
}

#Preview("Ошибка") {
    NavigationStack {
        ThoughtCaptureView(
            model: .preview(
                validationMessage: String(localized: "thoughtCapture.validation.empty")
            )
        )
    }
    .preferredColorScheme(.dark)
}
