import Foundation

extension CountdownItem {
    public static var SampleFutureTimer = CountdownItem(
        name: "Demo Item (Future)",
        date: .distantFuture,
        iconName: "sparkles",
        color: .blue
    )

    public static var SamplePastTimer = CountdownItem(
        name: "Demo Item (Past)",
        date: Date.now.addingTimeInterval(-86400),
        iconName: "clock.fill",
        color: .cyan
    )

    public static var Graduation = CountdownItem(
        name: "Graduation",
        date: Date.now.addingTimeInterval(60 * 60 * 24 * 30),
        iconName: "graduationcap.fill",
        color: .orange
    )
}
