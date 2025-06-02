//
//  AlarmGame.swift
//  AlarmKO
//
//  Created by Ziqa on 26/05/25.
//

import SwiftUI

enum AlarmGame: String, Hashable, CaseIterable {
    case punching = "Punching Game"
    case leveler = "Leveler Game"
    case heartrate = "HeartRate Game"
}

enum GameNavigationState: String {
    case home
    case game
}
