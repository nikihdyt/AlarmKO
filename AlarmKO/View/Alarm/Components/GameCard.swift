//
//  GameCard.swift
//  AlarmKOMainPage
//
//  Created by Joann ( Tang Chien ) on 28/05/25.
//

import SwiftUI

struct GameCard: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .opacity(0.7)
        }
        .padding()
        .frame(width: 160, height: 100)
        .background(LinearGradient(colors: [Color.green.opacity(0.6), Color.teal], startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
    }
}
