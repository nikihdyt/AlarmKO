//
//  Alarm.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import Foundation
import SwiftData

@Model
class Alarm : Identifiable {
    var id = UUID()
    var time: Date
    var alarmRepeat: String
    var label: String
    var game: String
    var sound: String
    var isActive: Bool
    
    init(id: UUID = UUID(), time: Date, alarmRepeat: String, label: String, game: String, sound: String, isActive: Bool) {
        self.id = id
        self.time = time
        self.alarmRepeat = alarmRepeat
        self.label = label
        self.game = game
        self.sound = sound
        self.isActive = isActive
    }
}
