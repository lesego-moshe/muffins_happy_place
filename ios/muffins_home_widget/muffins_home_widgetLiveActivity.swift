//
//  muffins_home_widgetLiveActivity.swift
//  muffins_home_widget
//
//  Created by Lesego Moshe on 2023/10/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct muffins_home_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct muffins_home_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: muffins_home_widgetAttributes.self) { context in
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

extension muffins_home_widgetAttributes {
    fileprivate static var preview: muffins_home_widgetAttributes {
        muffins_home_widgetAttributes(name: "World")
    }
}

extension muffins_home_widgetAttributes.ContentState {
    fileprivate static var smiley: muffins_home_widgetAttributes.ContentState {
        muffins_home_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: muffins_home_widgetAttributes.ContentState {
         muffins_home_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: muffins_home_widgetAttributes.preview) {
   muffins_home_widgetLiveActivity()
} contentStates: {
    muffins_home_widgetAttributes.ContentState.smiley
    muffins_home_widgetAttributes.ContentState.starEyes
}
