import AppIntents

public struct OpenCountdownIntent: OpenIntent, TargetContentProvidingIntent {
    
    public static let title: LocalizedStringResource = "Open Countdown"

    @Parameter(title: "Countdown", requestValueDialog: "Which Countdown?")
    public var target: CountdownEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$target)")
    }
    
    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        AppIntentNavigationStore.requestOpenCountdown(id: target.id)
        return .result()
    }
}
