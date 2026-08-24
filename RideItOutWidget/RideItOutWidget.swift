//
//  RideItOutWidget.swift
//  RideItOutWidget
//
//  Created by Dloyd on 8/23/26.
//

import WidgetKit
import SwiftUI

private extension Color {
    static let widgetBackground  = Color(red: 0.051, green: 0.059, blue: 0.102) // #0D0F1A
    static let widgetAccentCyan  = Color(red: 0.310, green: 0.765, blue: 0.969) // #4FC3F7
    static let widgetTextPrimary = Color(red: 0.941, green: 0.949, blue: 1.000) // #F0F2FF
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct RideItOutWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Ambient cyan glow, echoing the app's launch screen
            Rectangle()
                .stroke(Color.widgetAccentCyan, lineWidth: 10)
                .blur(radius: 18)
                .opacity(0.18)

            Text("Ride It\nOut")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.widgetTextPrimary)
                .multilineTextAlignment(.center)
                .tracking(-0.5)
        }
        .containerBackground(Color.widgetBackground, for: .widget)
    }
}

struct RideItOutWidget: Widget {
    let kind: String = "RideItOutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RideItOutWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ride It Out")
        .description("Tap to jump straight into Ride It Out.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    RideItOutWidget()
} timeline: {
    SimpleEntry(date: .now)
}
