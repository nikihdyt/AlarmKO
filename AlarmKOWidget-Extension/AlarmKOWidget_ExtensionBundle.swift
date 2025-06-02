//
//  AlarmKOWidget_ExtensionBundle.swift
//  AlarmKOWidget-Extension
//
//  Created by Niki Hidayati on 02/06/25.
//

import WidgetKit
import SwiftUI

@main
struct AlarmKOWidget_ExtensionBundle: Widget {
    let kind: String = "AlarmWidget"
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AlarmKOWidget_ExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("AlarmKO Widget")
        .contentMarginsDisabled()
        
    }
}
