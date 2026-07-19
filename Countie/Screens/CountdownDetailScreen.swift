//
//  CountdownDetailView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 24/7/25.
//

import AppIntents
import ConfettiSwiftUI
import SwiftUI
import UIKit

struct CountdownDetailView: View {
    @EnvironmentObject private var countdownStore: CountdownStore
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    private let countdown: CountdownItem
    private let onClose: (() -> Void)?

    @State private var isConfirmDeletePresented = false
    @State private var now = Date()
    @State private var timer: Timer?
    @State private var confettiTrigger = 0
    @State private var hasCelebratedCompletion = false
    @State private var isShareErrorPresented = false
    @State private var isShareSheetPresented = false
    @State private var sharedFileURL: URL?

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
        countdownRemainingValues(from: now, to: countdown.date)
    }

    private var progress: Float {
        countdownProgress(
            countSince: countdown.countSince,
            targetDate: countdown.date,
            now: now
        )
    }

    init(countdown: CountdownItem, onClose: (() -> Void)? = nil) {
        self.countdown = countdown
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            CountdownDetailBackground(tint: countdown.eventTintColor)

            CountdownDetailContent(
                iconName: countdown.resolvedIconName,
                tint: countdown.eventTintColor,
                progress: progress,
                name: countdown.name,
                formattedDateTime: countdown.formattedDateTimeString,
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
        .sheet(
            isPresented: $isShareSheetPresented,
            onDismiss: removeSharedFile
        ) {
            if let sharedFileURL {
                CountdownActivityView(
                    fileURL: sharedFileURL,
                    isPresented: $isShareSheetPresented
                )
            }
        }
        .alert(
            "Unable to Share Countdown",
            isPresented: $isShareErrorPresented
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The countdown image could not be created. Please try again.")
        }
        .userActivity("com.nabilridhwan.countie.countdown", element: countdown.id) { _, activity in
            activity.title = countdown.name
            activity.appEntityIdentifier = CountdownEntityContext.identifier(for: countdown)
        }
        .toolbar {
            ToolbarItem {
                Button(action: shareCountdown) {
                    Label("Share Countdown", systemImage: "square.and.arrow.up")
                        .labelStyle(.titleAndIcon)
                }
            }

            ToolbarItem {
                Button(action: presentDeleteConfirmation) {
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.red)
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

    @MainActor
    private func shareCountdown() {
        removeSharedFile()

        guard let image = CountdownShareRenderer.render(
            countdown: countdown,
            now: now,
            colorScheme: colorScheme,
            locale: locale
        ), let pngData = image.pngData() else {
            isShareErrorPresented = true
            return
        }

        do {
            let directory = FileManager.default.temporaryDirectory
                .appending(path: "CountieShare", directoryHint: .isDirectory)
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )

            let fileURL = directory.appending(
                path: "countie-\(countdown.id.uuidString).png",
                directoryHint: .notDirectory
            )
            try pngData.write(to: fileURL, options: .atomic)

            sharedFileURL = fileURL
            isShareSheetPresented = true
        } catch {
            isShareErrorPresented = true
        }
    }

    private func removeSharedFile() {
        guard let sharedFileURL else { return }
        try? FileManager.default.removeItem(at: sharedFileURL)
        self.sharedFileURL = nil
    }

    private func deleteCountdown() {
        countdownStore.deleteCountdown(countdown)
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
    let iconName: String
    let tint: Color
    let progress: Float
    let name: String
    let formattedDateTime: String
    let remainingValues: [CountdownRemainingValue]

    var body: some View {
        VStack {
            CountdownHeroSection(
                iconName: iconName,
                tint: tint,
                progress: progress
            )
                .padding(.bottom, 40)

            CountdownInfoSection(
                name: name,
                formattedDateTime: formattedDateTime,
                remainingValues: remainingValues
            )
        }
    }
}

private struct CountdownHeroSection: View {
    let iconName: String
    let tint: Color
    let progress: Float

    var body: some View {
        CircularEventIconView(
            iconName: iconName,
            tint: tint,
            progress: progress,
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
                .foregroundStyle(.secondary)
                .frame(minWidth: 36)
        }
    }
}

@MainActor
enum CountdownShareRenderer {
    static let outputWidth = 1_080
    static let outputHeight = 1_920

    static func render(
        countdown: CountdownItem,
        now: Date,
        colorScheme: ColorScheme,
        locale: Locale
    ) -> UIImage? {
        let artwork = CountdownShareArtwork(
            iconName: countdown.resolvedIconName,
            tint: countdown.eventTintColor,
            progress: countdownProgress(
                countSince: countdown.countSince,
                targetDate: countdown.date,
                now: now
            ),
            name: countdown.name,
            formattedDateTime: countdown.formattedDateTimeString,
            remainingValues: countdownRemainingValues(
                from: now,
                to: countdown.date
            )
        )
        .environment(\.colorScheme, colorScheme)
        .environment(\.locale, locale)

        let renderer = ImageRenderer(content: artwork)
        renderer.proposedSize = ProposedViewSize(width: 360, height: 640)
        renderer.scale = 3
        renderer.isOpaque = true
        return renderer.uiImage
    }
}

private struct CountdownShareArtwork: View {
    let iconName: String
    let tint: Color
    let progress: Float
    let name: String
    let formattedDateTime: String
    let remainingValues: [CountdownRemainingValue]

    var body: some View {
        ZStack {
            CountdownDetailBackground(tint: tint)

            VStack(spacing: 8) {
                Spacer(minLength: 0)

                CountdownDetailContent(
                    iconName: iconName,
                    tint: tint,
                    progress: progress,
                    name: name,
                    formattedDateTime: formattedDateTime,
                    remainingValues: remainingValues
                )

                Spacer(minLength: 0)

                CountdownShareBranding()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(width: 360, height: 640)
        .clipped()
    }
}

private struct CountdownShareBranding: View {
    var body: some View {
        Image("OnboardingLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 28, height: 28)
            .accessibilityHidden(true)
    }
}

private struct CountdownActivityView: UIViewControllerRepresentable {
    let fileURL: URL
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, _, _, _ in
            context.coordinator.dismiss()
        }
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}

    final class Coordinator {
        private let isPresented: Binding<Bool>

        init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }

        func dismiss() {
            Task { @MainActor in
                isPresented.wrappedValue = false
            }
        }
    }
}

private func countdownRemainingValues(
    from now: Date,
    to targetDate: Date
) -> [CountdownRemainingValue] {
    let components = Calendar.autoupdatingCurrent.dateComponents(
        [.day, .hour, .minute, .second],
        from: now,
        to: targetDate
    )

    return [
        CountdownRemainingValue(value: max(0, components.day ?? 0), unit: "days"),
        CountdownRemainingValue(value: max(0, components.hour ?? 0), unit: "hours"),
        CountdownRemainingValue(value: max(0, components.minute ?? 0), unit: "minutes"),
        CountdownRemainingValue(value: max(0, components.second ?? 0), unit: "seconds"),
    ]
}

private func countdownProgress(
    countSince: Date,
    targetDate: Date,
    now: Date
) -> Float {
    let total = targetDate.timeIntervalSince(countSince)
    guard total > 0 else { return 1 }

    let elapsed = now.timeIntervalSince(countSince)
    return Float(min(max(elapsed / total, 0), 1))
}

#Preview {
    CountdownDetailView(countdown: .Graduation)
}
