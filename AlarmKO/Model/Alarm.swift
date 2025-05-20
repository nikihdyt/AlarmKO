//
//  Alarm.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import Foundation

struct Alarm: Identifiable {
    let id = UUID()
    var time: Date
    var alarmRepeat: String
    var label: String
    var game: String
    var sound: String
    var isActive: Bool
}
