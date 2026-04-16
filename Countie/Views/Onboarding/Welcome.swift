//
//  Welcome.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Welcome: View {
    private let sampleEvents: [AnimatedWelcomeEvent] = [
        .init(symbol: "graduationcap.fill", title: "Graduation", subtitle: "7 days", tint: Color(red: 1.0, green: 0.57, blue: 0.28), angle: .degrees(-145)),
        .init(symbol: "airplane.departure", title: "Tokyo Trip", subtitle: "12 days", tint: Color(red: 1.0, green: 0.45, blue: 0.58), angle: .degrees(-108)),
        .init(symbol: "gift.fill", title: "Dad's Birthday", subtitle: "16 days", tint: Color(red: 1.0, green: 0.36, blue: 0.64), angle: .degrees(-70)),
        .init(symbol: "briefcase.fill", title: "First Day", subtitle: "20 days", tint: Color(red: 0.77, green: 0.34, blue: 0.96), angle: .degrees(-28)),
        .init(symbol: "theatermasks.fill", title: "Concert Night", subtitle: "23 days", tint: Color(red: 0.37, green: 0.52, blue: 1.0), angle: .degrees(24)),
        .init(symbol: "heart.fill", title: "Anniversary", subtitle: "31 days", tint: Color(red: 0.25, green: 0.73, blue: 0.95), angle: .degrees(66)),
        .init(symbol: "figure.run", title: "Half Marathon", subtitle: "42 days", tint: Color(red: 0.31, green: 0.82, blue: 0.74), angle: .degrees(108)),
        .init(symbol: "sparkles", title: "New Year", subtitle: "60 days", tint: Color(red: 0.93, green: 0.72, blue: 0.41), angle: .degrees(146)),
    ]

    var body: some View {
        VStack {
            AnimatedWelcomeHero(events: sampleEvents)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 88)
                .zIndex(0)
            
            VStack(spacing: 12) {
                Text("Countie")
                    .font(.largeTitle)
                    .bold()

                Text("Good things take time.")
                    .foregroundStyle(.secondary)

                Text("We’ll keep track of it for you.")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .zIndex(1)
        }
        .multilineTextAlignment(.center)
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AnimatedWelcomeHero: View {
    let events: [AnimatedWelcomeEvent]

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let base = min(width, 320)
            let iconSize = base * 0.34
            let orbitRadius = base * 0.39

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentColor.opacity(0.16),
                                Color.accentColor.opacity(0.05),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 24,
                            endRadius: orbitRadius + 24
                        )
                    )
                    .frame(width: orbitRadius * 2.15, height: orbitRadius * 2.15)

                ForEach([
                    orbitRadius * 1.35,
                    orbitRadius * 1.72,
                    orbitRadius * 2.05
                ], id: \.self) { ringRadius in
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.57, blue: 0.28),
                                    Color(red: 1.0, green: 0.36, blue: 0.64),
                                    Color(red: 0.49, green: 0.40, blue: 0.98),
                                    Color(red: 0.25, green: 0.73, blue: 0.95),
                                    Color(red: 1.0, green: 0.57, blue: 0.28),
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 12])
                        )
                        .frame(width: ringRadius * 2, height: ringRadius * 2)
                        .opacity(0.16)
                }

                ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                    AnimatedEventBubble(
                        event: event,
                        orbitRadius: orbitRadius,
                        index: index,
                        totalEvents: events.count
                    )
                }

                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: iconSize * 1.35, height: iconSize * 1.35)
                        .blur(radius: 22)

                    RoundedRectangle(cornerRadius: iconSize * 0.26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.94)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 18, y: 8)

//                    RoundedRectangle(cornerRadius: iconSize * 0.26, style: .continuous)
//                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)

                    Image("OnboardingLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(iconSize * 0.16)
                }
                .frame(width: iconSize, height: iconSize)
            }
            .frame(width: width, height: height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .allowsHitTesting(false)
    }
}

private struct AnimatedEventBubble: View {
    let event: AnimatedWelcomeEvent
    let orbitRadius: CGFloat
    let index: Int
    let totalEvents: Int

    private let sequenceDuration: TimeInterval = 16
    private let activeWindow: TimeInterval = 3.35

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let slot = sequenceDuration / Double(totalEvents)
            let slotStart = Double(index) * slot
            let globalTime = timeline.date.timeIntervalSinceReferenceDate
            let cycle = positiveRemainder(globalTime, sequenceDuration)
            let localTime = positiveRemainder(cycle - slotStart, sequenceDuration)
            let isVisible = localTime <= activeWindow
            let progress = isVisible ? localTime / activeWindow : 1
            let startPoint = point(for: event.angle, radius: orbitRadius * 1.28)
            let fadeInPhase = normalized(progress, start: 0.0, end: 0.18)
            let holdPhase = normalized(progress, start: 0.18, end: 0.34)
            let travelPhase = normalized(progress, start: 0.34, end: 0.78)
            let fadeOutPhase = normalized(progress, start: 0.66, end: 1.0)
            let easedTravel = easeInOut(travelPhase)
            let currentX = startPoint.x * (1 - easedTravel)
            let currentY = startPoint.y * (1 - easedTravel)
            let opacity = isVisible ? min(fadeInPhase * 0.98, 0.98) * (1 - fadeOutPhase) : 0
            let scale = 0.94 + (holdPhase * 0.06) - (travelPhase * 0.28)

            WelcomeEventBubbleCard(event: event)
                .scaleEffect(scale)
                .opacity(opacity)
                .blur(radius: fadeOutPhase > 0.45 ? 2.5 : 0)
                .offset(x: currentX, y: currentY)
        }
    }

    private func point(for angle: Angle, radius: CGFloat) -> CGPoint {
        let radians = Double(angle.radians)
        return CGPoint(
            x: CGFloat(cos(radians)) * radius,
            y: CGFloat(sin(radians)) * radius
        )
    }

    private func normalized(_ value: Double, start: Double, end: Double) -> Double {
        guard end > start else { return 0 }
        return min(max((value - start) / (end - start), 0), 1)
    }

    private func positiveRemainder(_ value: Double, _ divisor: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: divisor)
        return remainder >= 0 ? remainder : remainder + divisor
    }

    private func easeInOut(_ value: Double) -> Double {
        value * value * (3 - 2 * value)
    }
}

private struct WelcomeEventBubbleCard: View {
    let event: AnimatedWelcomeEvent

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: event.symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(event.tint)
                .frame(width: 28, height: 28)
                .background(event.tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(event.subtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

private struct AnimatedWelcomeEvent {
    let symbol: String
    let title: String
    let subtitle: String
    let tint: Color
    let angle: Angle
}

#Preview {
    Welcome()
}
