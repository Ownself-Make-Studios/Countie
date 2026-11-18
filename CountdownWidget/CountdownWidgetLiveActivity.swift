//
//  CountdownWidgetLiveActivity.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CountdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var iconName: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CountdownWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Label("Hello", systemImage: context.state.iconName)
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label("Bottom", systemImage: context.state.iconName)
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Image(systemName: context.state.iconName)
            } minimal: {
                Image(systemName: context.state.iconName)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CountdownWidgetAttributes {
    fileprivate static var preview: CountdownWidgetAttributes {
        CountdownWidgetAttributes(name: "World")
    }
}

extension CountdownWidgetAttributes.ContentState {
    fileprivate static var smiley: CountdownWidgetAttributes.ContentState {
        CountdownWidgetAttributes.ContentState(iconName: "sparkles")
     }
     
     fileprivate static var starEyes: CountdownWidgetAttributes.ContentState {
         CountdownWidgetAttributes.ContentState(iconName: "party.popper.fill")
     }
}

#Preview("Notification", as: .content, using: CountdownWidgetAttributes.preview) {
   CountdownWidgetLiveActivity()
} contentStates: {
    CountdownWidgetAttributes.ContentState.smiley
    CountdownWidgetAttributes.ContentState.starEyes
}
