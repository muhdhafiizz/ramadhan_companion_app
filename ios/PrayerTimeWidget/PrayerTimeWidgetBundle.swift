//
//  PrayerTimeWidgetBundle.swift
//  PrayerTimeWidget
//
//  Created by Muhammad Hafiz Mohd Azahar on 04/09/2025.
//

import WidgetKit
import SwiftUI

@main
struct PrayerTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerTimeWidget()
        PrayerTimeWidgetControl()
        PrayerTimeWidgetLiveActivity()
    }
}
