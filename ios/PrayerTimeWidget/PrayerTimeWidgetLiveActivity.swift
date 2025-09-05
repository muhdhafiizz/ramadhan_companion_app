//
//  PrayerTimeWidgetLiveActivity.swift
//  PrayerTimeWidget
//
//  Created by Muhammad Hafiz Mohd Azahar on 04/09/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PrayerTimeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PrayerTimeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerTimeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PrayerTimeWidgetAttributes {
    fileprivate static var preview: PrayerTimeWidgetAttributes {
        PrayerTimeWidgetAttributes(name: "World")
    }
}

extension PrayerTimeWidgetAttributes.ContentState {
    fileprivate static var smiley: PrayerTimeWidgetAttributes.ContentState {
        PrayerTimeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PrayerTimeWidgetAttributes.ContentState {
         PrayerTimeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PrayerTimeWidgetAttributes.preview) {
   PrayerTimeWidgetLiveActivity()
} contentStates: {
    PrayerTimeWidgetAttributes.ContentState.smiley
    PrayerTimeWidgetAttributes.ContentState.starEyes
}
