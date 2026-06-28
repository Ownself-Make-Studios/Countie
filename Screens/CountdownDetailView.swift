//
//  CountdownDetailView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 24/7/25.
//

import SwiftUI
import ConfettiSwiftUI

struct CountdownDetailView: View {
    @EnvironmentObject private var store: CountdownStore
    @Environment(\.dismiss) private var dismiss

    private let countdown: CountdownItem
    private let onClose: (() -> Void)?

    @State private var isConfirmDeletePresented = false
    @State private var now = Date()
    @State private var timer: Timer?
    @State private var confettiTrigger = 0
    @State private var hasCelebratedCompletion = false

    private var confettiContent: [ConfettiType] {
        [
            .shape(.circle),
            .shape(.triangle),
            .shape(.square),
            .shape(.slimRectangle),
        ]
    }

    private var isEditable: Bool {
        countdown.date >= now
    }

    private var remainingValues: [CountdownRemainingValue] {
        let components = Calendar.autoupdatingCurrent.dateComponents(
            [.day, .hour, .minute, .second],
            from: now,
            to: countdown.date
        )

        return [
            CountdownRemainingValue(value: max(0, components.day ?? 0), unit: "days"),
            CountdownRemainingValue(value: max(0, components.hour ?? 0), unit: "hours"),
            CountdownRemainingValue(value: max(0, components.minute ?? 0), unit: "minutes"),
            CountdownRemainingValue(value: max(0, components.second ?? 0), unit: "seconds"),
        ]
    }

    init(countdown: CountdownItem, onClose: (() -> Void)? = nil) {
        self.countdown = countdown
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            CountdownDetailBackground(tint: countdown.eventTintColor)

            CountdownDetailContent(
                countdown: countdown,
                remainingValues: remainingValues
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: close)
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
        .onAppear(perform: startTimer)
        .onChange(of: now) { _, newValue in
            handleNowChange(newValue)
        }
        .onDisappear(perform: stopTimer)
        .toolbar {
            ToolbarItem {
                Button(action: presentDeleteConfirmation) {
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.red)
                }
                .confirmationDialog(
                    "Are you sure you want to delete this countdown?",
                    isPresented: $isConfirmDeletePresented,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive, action: deleteCountdown)
                }
            }

            if isEditable {
                ToolbarItem {
                    NavigationLink(
                        destination: AddCountdownView(countdownToEdit: countdown)
                    ) {
                        Label("Edit Countdown", systemImage: "square.and.pencil")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
    }

    private func presentDeleteConfirmation() {
        isConfirmDeletePresented = true
    }

    private func deleteCountdown() {
        store.deleteCountdown(countdown)
        onClose?()
        close()
    }

    private func close() {
        dismiss()
    }

    private func startTimer() {
        now = Date()
        hasCelebratedCompletion = countdown.date <= now
        stopTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            withAnimation(.snappy(duration: 0.32)) {
                now = Date()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func handleNowChange(_ newValue: Date) {
        guard !hasCelebratedCompletion, newValue >= countdown.date else { return }
        hasCelebratedCompletion = true
        confettiTrigger += 1
    }
}

private struct CountdownDetailBackground: View {
    let tint: Color

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            tint.opacity(0.5),
                            Color.backgroundThemeRespectable.mix(with: .white, by: 0.16),
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CountdownDetailContent: View {
    let countdown: CountdownItem
    let remainingValues: [CountdownRemainingValue]

    var body: some View {
        VStack {
            CountdownHeroSection(countdown: countdown)
                .padding(.bottom, 40)

            CountdownInfoSection(
                name: countdown.name,
                formattedDateTime: countdown.formattedDateTimeString,
                remainingValues: remainingValues
            )
        }
    }
}

private struct CountdownHeroSection: View {
    let countdown: CountdownItem

    var body: some View {
        CircularEventIconView(
            iconName: countdown.resolvedIconName,
            tint: countdown.eventTintColor,
            progress: Float(countdown.progress),
            showProgress: true,
            width: 200,
            brightness: 0.3,
            lineWidth: 14,
            gap: 40,
            iconSize: 60
        )
    }
}

private struct CountdownInfoSection: View {
    let name: String
    let formattedDateTime: String
    let remainingValues: [CountdownRemainingValue]

    var body: some View {
        VStack {
            Text(name)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text(formattedDateTime)
                .font(.subheadline)
                .opacity(0.5)
                .multilineTextAlignment(.center)

            CountdownRemainingRow(remainingValues: remainingValues)
                .padding(.vertical, 10)
        }
    }
}

private struct CountdownRemainingRow: View {
    let remainingValues: [CountdownRemainingValue]

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(remainingValues) { item in
                    CountdownTimeUnitCard(
                        value: item.value,
                        unit: item.unit
                    )
                }
            }
        }
    }
}

private struct CountdownRemainingValue: Identifiable {
    let value: Int
    let unit: String

    var id: String { unit }
}

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

#Preview {
    CountdownDetailView(countdown: .Graduation)
}
