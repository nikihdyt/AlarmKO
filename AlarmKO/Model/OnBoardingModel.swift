//
//  OnBoarding.swift
//  AlarmKO
//
//  Created by Ziqa on 25/05/25.
//

import SwiftUI

struct OnBoardingModel: Identifiable, Hashable {
    var id: UUID = .init()
    var onBoardingBackground: String
    var title: String
    var subtitle: String
}

var onBoardingScreens: [OnBoardingModel] = [
    .init(onBoardingBackground: "OnBoarding 1", title: "Welcome to\nAlarmKO", subtitle: "Normal alarms can’t wake you up? \nSnooze buttons too easy?"),
    .init(onBoardingBackground: "OnBoarding 2", title: "Punch to Wake \nNo Excuses", subtitle: "This alarm won’t stop by tapping. \nPunch it till it gives up."),
    .init(onBoardingBackground: "OnBoarding 3", title: "Allow \nNotifications", subtitle: "If notifications are turned off, you won’t see or hear anything when alarms ring."),
    .init(onBoardingBackground: "OnBoarding 4", title: "Sound On!", subtitle: "To win the battle,\nkeep your silent switch off.\nNo sound, no challenge!"),
]
