import SwiftUI
import UIKit

enum OnboardingMode {
    case firstLaunch
    case settings
}

struct OnboardingFlowView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    let mode: OnboardingMode
    let onFinish: () -> Void

    @State private var selectedPage = 0
    @State private var calendarStatus = CalendarAccessManager.permissionStatus()
    @State private var notificationStatus: NotificationPermissionStatus = .notDetermined
    @State private var isRequestingCalendarPermission = false
    @State private var isRequestingNotificationPermission = false

    private let pageCount = 3

    private var surfaceColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    private var isLastPage: Bool {
        selectedPage == pageCount - 1
    }
    
    private var isFirstPage: Bool {
        selectedPage == 0
    }

    private var finishTitle: String {
        mode == .firstLaunch ? "Start Using Countie" : "Done"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TabView(selection: $selectedPage) {
                    OnboardingPage {
                        Welcome()
                    }
                    .tag(0)

                    OnboardingPage {
                        Countdown()
                    }
                    .tag(1)

                    OnboardingPage {
                        permissionsView
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                OnboardingPageIndicator(
                    pageCount: pageCount,
                    selectedPage: selectedPage
                )
                .padding(.bottom, 12)
            }
            .background(surfaceColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if mode == .firstLaunch || mode == .settings {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onFinish()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 28, height: 28)
                                .background(.thinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Close onboarding")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()

                    Button(isFirstPage ? "Get Started" : isLastPage ? finishTitle : "Continue") {
                        if isLastPage {
                            onFinish()
                        } else {
                            withAnimation(.easeInOut(duration: 0.32)) {
                                selectedPage += 1
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                .background(surfaceColor)
            }
        }
        .background(surfaceColor)
        .task {
            await refreshPermissionState()
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            Task {
                await refreshPermissionState()
            }
        }
    }

    private var permissionsView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .center, spacing: 10) {
                Text("Stay in sync")
                    .font(.title)
                    .bold()
                Text("Connect your calendar and notifications so Countie can keep important moments close and remind you before they happen.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            PermissionCard(
                title: "Calendar Events",
                systemImage: "calendar.badge.plus",
                description: "Import events from your calendar so you can create countdowns in a couple of taps.",
                statusText: calendarStatusText,
                isAuthorized: calendarStatus.isAuthorized,
                actionTitle: calendarActionTitle,
                isLoading: isRequestingCalendarPermission,
                action: requestCalendarPermission,
                settingsAction: openAppSettingsIfNeeded(showingForDeniedState: isCalendarDenied)
            )

            PermissionCard(
                title: "Notifications",
                systemImage: "bell.badge",
                description: "Allow reminders so Countie can notify you before an event reaches its countdown target.",
                statusText: notificationStatusText,
                isAuthorized: notificationStatus.isAuthorized,
                actionTitle: notificationActionTitle,
                isLoading: isRequestingNotificationPermission,
                action: requestNotificationPermission,
                settingsAction: openAppSettingsIfNeeded(showingForDeniedState: isNotificationDenied)
            )

            Text("You can keep using Countie even if you skip permissions for now.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(28)
    }

    private var isCalendarDenied: Bool {
        calendarStatus == .denied || calendarStatus == .restricted || calendarStatus == .writeOnly
    }

    private var isNotificationDenied: Bool {
        notificationStatus == .denied
    }

    private var calendarStatusText: String {
        switch calendarStatus {
        case .authorized:
            return "Allowed"
        case .writeOnly:
            return "Limited access"
        case .notDetermined:
            return "Not requested yet"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized:
            return "Allowed"
        case .provisional:
            return "Allowed quietly"
        case .ephemeral:
            return "Allowed temporarily"
        case .notDetermined:
            return "Not requested yet"
        case .denied:
            return "Denied"
        }
    }

    private var calendarActionTitle: String {
        calendarStatus.isAuthorized ? "Granted" : "Allow Calendar Access"
    }

    private var notificationActionTitle: String {
        notificationStatus.isAuthorized ? "Granted" : "Allow Notifications"
    }

    private func requestCalendarPermission() {
        guard !calendarStatus.isAuthorized else { return }

        Task {
            isRequestingCalendarPermission = true
            defer { isRequestingCalendarPermission = false }
            _ = await CalendarAccessManager.requestPermission()
            await refreshPermissionState()
        }
    }

    private func requestNotificationPermission() {
        guard !notificationStatus.isAuthorized else { return }

        Task {
            isRequestingNotificationPermission = true
            defer { isRequestingNotificationPermission = false }
            _ = await CountdownReminderScheduler.requestNotificationPermission()
            await refreshPermissionState()
        }
    }

    private func refreshPermissionState() async {
        calendarStatus = CalendarAccessManager.permissionStatus()
        notificationStatus = await CountdownReminderScheduler.notificationPermissionStatus()
    }

    private func openAppSettingsIfNeeded(showingForDeniedState: Bool) -> (() -> Void)? {
        guard showingForDeniedState else { return nil }
        return {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            openURL(url)
        }
    }
}

private struct OnboardingPage<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack {
                content
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, minHeight: 520)
            .padding(.bottom, 120)
        }
    }
}

private struct OnboardingPageIndicator: View {
    let pageCount: Int
    let selectedPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule(style: .circular)
                    .fill(index == selectedPage ? Color.primary : Color.secondary.opacity(0.25))
                    .frame(width: index == selectedPage ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: selectedPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("Step \(selectedPage + 1) of \(pageCount)")
    }
}

private struct PermissionCard: View {
    let title: String
    let systemImage: String
    let description: String
    let statusText: String
    let isAuthorized: Bool
    let actionTitle: String
    let isLoading: Bool
    let action: () -> Void
    let settingsAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            Text(description)
                .foregroundStyle(.secondary)

            Label(statusText, systemImage: isAuthorized ? "checkmark.circle.fill" : "questionmark.circle")
                .foregroundStyle(isAuthorized ? .green : .secondary)

            Button(actionTitle) {
                action()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAuthorized || isLoading)

            if let settingsAction {
                Button("Open Settings") {
                    settingsAction()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    OnboardingFlowView(mode: .firstLaunch) {}
}
