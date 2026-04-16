//
//  CountdownDetailView.swift
//  noma
//
//  Created by Nabil Ridhwan on 24/7/25.
//

import SwiftUI
import ConfettiSwiftUI

private struct CountdownTimeUnitCard: View {
    let value: Int
    let unit: String

    private var formattedValue: String {
        String(format: "%02d", value)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(formattedValue)
                .font(.title2.monospacedDigit())
                .fontWeight(.bold)
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy(duration: 0.32), value: value)
                .frame(minWidth: 36, minHeight: 36)
                .padding(3)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            Color.primary.opacity(0.2),
                            lineWidth: 1
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground).opacity(0.7))
                        )
                )

            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(minWidth: 36)
        }
    }
}

struct CountdownDetailView: View {
    @EnvironmentObject var store: CountdownStore

    @AppStorage("showProgress") private var showProgress: Bool = true

    @Environment(\.dismiss) private var dismiss
    var countdown: CountdownItem
    @State private var isConfirmDeletePresented: Bool = false
    var onClose: (() -> Void)? = nil

    @State private var now: Date = Date()
    @State private var timer: Timer? = nil
    @State private var confettiTrigger: Int = 0
    @State private var hasCelebratedCompletion: Bool = false

    private var confettiColors: [Color] {
        [
            Color(vibrantDominantColorOf: countdown.emoji ?? "") ?? .accentColor,
            .orange,
            .yellow,
            .pink,
            .mint,
        ]
    }

    private var confettiContent: [ConfettiType] {
        let emoji = countdown.emoji.flatMap { $0.isEmpty ? nil : $0 } ?? "🎉"
        return [
            .text(emoji),
            .shape(.circle),
            .shape(.triangle),
            .shape(.square),
            .shape(.slimRectangle),
        ]
    }

    private var remainingValues: [(value: Int, unit: String)] {
        let components = Calendar.autoupdatingCurrent.dateComponents(
            [.day, .hour, .minute, .second],
            from: now,
            to: countdown.date
        )

        return [
            (max(0, components.day ?? 0), "days"),
            (max(0, components.hour ?? 0), "hours"),
            (max(0, components.minute ?? 0), "minutes"),
            (max(0, components.second ?? 0), "seconds"),
        ]
    }

    func handleDelete() {
        store.deleteCountdown(countdown)
    }

    var body: some View {
        ZStack {

            Rectangle()
                .fill(
                    LinearGradient(
                        gradient:
                            Gradient(
                                colors: [
                                    Color(
                                        vibrantDominantColorOf: countdown.emoji
                                            ?? ""
                                    ) ?? .accentColor,
                                    Color.backgroundThemeRespectable.mix(
                                        with: .white,
                                        by: 0.16
                                    ),
                                ]
                            ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(.all)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            VStack {

                CircularEmojiView(
                    emoji: countdown.emoji ?? "",
                    progress: Float(countdown.progress),
                    showProgress: true,
                    width: 200,
                    brightness: 0.3,
                    lineWidth: 14,
                    gap: 40,
                    emojiSize: 60
                )
                .padding(.bottom, 40)

                VStack {
                    Text(countdown.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(countdown.formattedDateTimeString)
                        .font(.subheadline)
                        .opacity(0.5)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            ForEach(Array(remainingValues.enumerated()), id: \.offset) { _, item in
                                CountdownTimeUnitCard(
                                    value: item.value,
                                    unit: item.unit
                                )
                            }
                        }
                    }
                    .padding(.vertical, 10)

//                    Button {
//                        confettiTrigger += 1
//                    } label: {
//                        Label("Test Confetti", systemImage: "sparkles")
//                            .font(.caption.weight(.semibold))
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .controlSize(.small)
//                    .padding(.top, 8)

                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 100,
            confettis: confettiContent,
            confettiSize: 14,
            rainHeight: 900,
            fadesOut: true,
            openingAngle: .degrees(60),
            closingAngle: .degrees(360),
            radius: 300,
            repetitions: 1,
            repetitionInterval: 0.18,
            hapticFeedback: true
        )
        .onAppear {
            now = Date()
            hasCelebratedCompletion = countdown.date <= now
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                _ in
                withAnimation(.snappy(duration: 0.32)) {
                    now = Date()
                }
            }
        }
        .onChange(of: now) { _, newValue in
            guard !hasCelebratedCompletion, newValue >= countdown.date else { return }
            hasCelebratedCompletion = true
            confettiTrigger += 1
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .toolbar {

            ToolbarItem {
                Button(action: {
                    //                                        handleDelete()
                    isConfirmDeletePresented = true
                }) {
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.red)
                }
                .confirmationDialog(
                    "Are you sure you want to delete this countdown?",
                    isPresented: $isConfirmDeletePresented,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        print("Deleting countdown: \(countdown.name)")
                        // Remove from the list or perform deletion in your data model

                        handleDelete()
                        onClose?()
                        dismiss()
                    }
                }
            }

            countdown.date < Date()
                ? nil
                : ToolbarItem {
                    NavigationLink(
                        destination: AddCountdownView(
                            countdownToEdit: countdown
                        )
                    ) {
                        Label(
                            "Edit Countdown",
                            systemImage: "square.and.pencil"
                        )
                        .labelStyle(.titleAndIcon)
                    }
                }
        }

    }
}

#Preview {
    CountdownDetailView(
        countdown: .Graduation
    )
}
