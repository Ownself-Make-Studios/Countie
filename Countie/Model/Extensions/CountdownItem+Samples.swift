import Foundation

extension CountdownItem {
    public static var SampleFutureTimer = CountdownItem(
        name: "Demo Item (Future)",
        includeTime: true,
        date: .distantFuture,
        iconName: "sparkles",
        colorNameRaw: CountdownEventColor.blue.rawValue
    )

    public static var SamplePastTimer = CountdownItem(
        name: "Demo Item (Past)",
        includeTime: true,
        date: Date.now.addingTimeInterval(-86400),
        iconName: "clock.fill",
        colorNameRaw: CountdownEventColor.cyan.rawValue
    )

    public static var Graduation = CountdownItem(
        name: "Graduation",
        includeTime: false,
        date: Date.now.addingTimeInterval(60 * 60 * 24 * 30),
        iconName: "graduationcap.fill",
        colorNameRaw: CountdownEventColor.orange.rawValue
    )
}
