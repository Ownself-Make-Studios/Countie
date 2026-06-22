//
//  AppIntent.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Countdown Widget" }
    static var description: IntentDescription { "Access your countdowns from this widget!" }
    
    @Parameter(title: "Display Only Selected Countdown", default: false)
    var showSpecificCountdown: Bool?
    
    @Parameter(title: "Show Countdown Progress Bar", default: true)
    var showProgress: Bool?
    
    @Parameter(title: "Select Countdown to Display")
    var countdown: CountdownEntity?
    
    // Read "ParameterSummary"
    // https://developer.apple.com/documentation/appintents/widgetconfigurationintent
    static var parameterSummary: some ParameterSummary {
        When(\ConfigurationAppIntent.$showSpecificCountdown, .equalTo, true) {
            Summary {
                \.$showProgress
                \.$showSpecificCountdown
                \.$countdown
            }
        } otherwise: {
            Summary {
                \.$showProgress
                \.$showSpecificCountdown
            }
        }
    }
}
