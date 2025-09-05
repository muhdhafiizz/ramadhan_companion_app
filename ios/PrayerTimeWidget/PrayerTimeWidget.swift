//
//  PrayerTimeWidget.swift
//  PrayerTimeWidget
//
//  Created by Muhammad Hafiz Mohd Azahar on 04/09/2025.
//

import WidgetKit
import SwiftUI

struct PrayerTimeWidget: Widget {
    let kind: String = "PrayerTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Times")
        .description("Shows upcoming prayer times and countdown.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("Placeholder called")
        return SimpleEntry(
            date: Date(),
            fajr: "--", dhuhr: "--", asr: "--", maghrib: "--", isha: "--",
            nextPrayer: "--", countdown: "--"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("getSnapshot called")
        let entry = loadPrayerData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("getTimeline called")
        let entry = loadPrayerData()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }

    func loadPrayerData() -> SimpleEntry {
        // Use standard UserDefaults instead of app group
//        let userDefaults = UserDefaults(suiteName: "group.com.ramadhan_companion_app.pr")

        let userDefaults = UserDefaults.standard
        print("loadPrayerData called, userDefaults: \(userDefaults)")

        let fajr = userDefaults.string(forKey: "fajr") ?? "--"
        let dhuhr = userDefaults.string(forKey: "dhuhr") ?? "--"
        let asr = userDefaults.string(forKey: "asr") ?? "--"
        let maghrib = userDefaults.string(forKey: "maghrib") ?? "--"
        let isha = userDefaults.string(forKey: "isha") ?? "--"
        let nextPrayer = userDefaults.string(forKey: "next_prayer") ?? "--"
        let countdown = userDefaults.string(forKey: "countdown") ?? "--"

        print("Loaded prayer times: fajr=\(fajr), dhuhr=\(dhuhr), asr=\(asr), maghrib=\(maghrib), isha=\(isha), nextPrayer=\(nextPrayer), countdown=\(countdown)")

        return SimpleEntry(
            date: Date(),
            fajr: fajr,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha,
            nextPrayer: nextPrayer,
            countdown: countdown
        )
    }

}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let fajr, dhuhr, asr, maghrib, isha, nextPrayer, countdown: String
}

struct PrayerTimesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next: \(entry.nextPrayer) in \(entry.countdown) min")
                .font(.headline)
            Divider()
            Text("Fajr: \(entry.fajr)")
            Text("Dhuhr: \(entry.dhuhr)")
            Text("Asr: \(entry.asr)")
            Text("Maghrib: \(entry.maghrib)")
            Text("Isha: \(entry.isha)")
        }
        .padding()
    }
}
