import AppIntents

public struct OpenCountdownIntent: AppIntent {
    public static var title: LocalizedStringResource = "Open Countdown"
    public static var description = IntentDescription("Opens a countdown in Countie.")
    public static var openAppWhenRun = true

    @Parameter(title: "Countdown")
    public var countdown: CountdownEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$countdown)")
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        AppIntentNavigationStore.requestOpenCountdown(id: countdown.id)
        return .result(dialog: "Opening \(countdown.name).")
    }
}
