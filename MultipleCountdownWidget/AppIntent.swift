//
//  AppIntent.swift
//  MultipleCountdownWidget
//
//  Created by Nabil Ridhwan on 25/6/25.
//

import WidgetKit
import AppIntents

struct MultipleCountdownConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Show latest countdowns" }
    static var description: IntentDescription { "This widget shows the latest countdowns" }
}
