//
//  AlarmKOWidget_Extension.swift
//  AlarmKOWidget-Extension
//
//  Created by Niki Hidayati on 02/06/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HomeEntry {
        HomeEntry(date: Date(), wakeUpTime: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeEntry) -> ()) {
        let entry = HomeEntry(date: Date(), wakeUpTime: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeEntry>) -> ()) {
        let currentDate = Date()
        let wakeUpTime = AlarmWidgetData.loadWakeUpTimeDateComponent()
        
        print("Widget Provider: loaded wakeUpTime ", wakeUpTime)
        
        let entry = HomeEntry(
            date: currentDate,
            wakeUpTime: Calendar.current.date(from: wakeUpTime) ?? Date()
        )
        
        let entries: [HomeEntry] = [entry]
        
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
        
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct HomeEntry: TimelineEntry {
    let date: Date
    let wakeUpTime: Date
}

struct AlarmKOWidget_ExtensionEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.wakeUpTime)
    }

    var body: some View {
        
        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f
        }()
        
        let fullString = formatter.string(from: entry.wakeUpTime)
        let parts = fullString.components(separatedBy: " ")
        let timePart = parts.first ?? ""
        let periodPart = parts.count > 1 ? parts[1] : ""
        
        
        switch family {
            // MARK: Small Size Widget
            case .systemSmall:
                ZStack{
                    Image("dot1")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .offset(x: 60, y: -24)
                        .ignoresSafeArea()
                    
                    Image("dot2")
                        .resizable()
                        .frame(width: 40, height: 28)
                        .offset(x: -20, y: 66)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 1) {
                            Image("timer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                            
                            Text("Wake Up at")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(Color.black)
                        }
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(timePart)
                                .font(.system(size: 30, weight: .black))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(Color.black)
                            
                            Text(periodPart)
                                .font(.system(size: 12, weight: .semibold))
                                .baselineOffset(6)
                                .offset(x: 5, y: 0)
                                .foregroundColor(Color.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text(" Punch to wake")
                            .font(.system(size: 12, weight: .regular))
                            .offset(x: -2, y: 0)
                            .foregroundColor(Color.black.opacity(0.5))
                        
                    }
                    .padding()
                    .containerBackground(Color("PrimaryColor"), for: .widget)
                }
            
            // MARK: Lock Screen Widget
            case .accessoryCircular:
                Text(timeText)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .containerBackground(.fill.tertiary, for: .widget)
            
            
            // MARK: Medium Size Widget
            case .systemMedium:
                ZStack {
                    Color("MediumColor")
                    Image("dotMedium")
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            
                            HStack(spacing:6){
                                Image("timerMedium")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                Text("Wake Up at")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text(timePart + " " + periodPart)
                                .font(.system(size: 36, weight: .black))
                                .foregroundStyle(Color("PrimaryColor"))
                            
                            
                            HStack(spacing: 0) {
                                Text("Punch")
                                    .foregroundStyle(Color("PrimaryColor"))
                                    .font(.system(size: 12, weight: .regular))

                                Text(" to wake")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 12, weight: .regular))
                            }
                            .offset(x: -2, y: 0)
                        }
                        Spacer()
                        
                    }
                    .padding()
                    .containerBackground(Color("MediumColor"), for: .widget)
                }
            
            default:
                Text("Unsupported")
        }
    }
}

struct AlarmKOWidget_Extension: Widget {
    let kind: String = "AlarmKOWidget_Extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AlarmKOWidget_ExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AlarmKOWidget_ExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

//MARK: Widget Preview
#Preview(as: .systemSmall) {
    AlarmKOWidget_Extension()
} timeline: {
    HomeEntry(date: .now, wakeUpTime: Date())
    HomeEntry(date: .now, wakeUpTime: Date().addingTimeInterval(90 * 60))
}

#Preview(as: .systemMedium) {
    AlarmKOWidget_Extension()
} timeline: {
    HomeEntry(date: .now, wakeUpTime: Date().addingTimeInterval(90 * 60))
}
