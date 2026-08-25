//
//  RideItOutWidget.swift
//  RideItOutWidget
//
//  Created by Dloyd on 8/23/26.
//

import WidgetKit
import SwiftUI

// The widget runs in its own extension bundle and can't import the app
// target's Colors.swift / Font+Display.swift, so the app's palette and
// wordmark font are mirrored here to match the rest of the app.
private extension Color {
    static func scheme(_ light: Color, _ dark: Color) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }

    static let widgetBackground = scheme(Color(hex: 0xF5EAD8), Color(hex: 0x17130F))
    static let widgetTextPrimary = scheme(Color(hex: 0x201E1D), Color(hex: 0xF5EAD8))
    static let widgetAccent = scheme(Color(hex: 0xC67139), Color(hex: 0xF6A06B))

    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

private extension Font {
    static func displaySerif(size: CGFloat) -> Font {
        if UIFont(name: "InstrumentSerif-Regular", size: size) != nil {
            return .custom("InstrumentSerif-Regular", size: size)
        }
        return .system(size: size, weight: .regular, design: .serif)
    }
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
        VStack(alignment: .leading, spacing: 0) {
            Image("AppIconMark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Spacer()

            Text("Ride It Out")
                .font(.displaySerif(size: 22))
                .foregroundColor(.widgetTextPrimary)
                .lineLimit(2)

            Rectangle()
                .fill(Color.widgetAccent)
                .frame(width: 22, height: 3)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
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
