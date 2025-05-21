//
//  MainView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var alarms: [Alarm]
    @State private var selectedAlarm: Alarm? = nil
    @State private var showSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Button(action: {
                        selectedAlarm = nil
                        showSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 12)
                    
                    Text("Alarms")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 153, height: 71)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    List {
                        ForEach(alarms) { alarm in
                            AlarmCard(alarm: alarm)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .onTapGesture {
                                    selectedAlarm = alarm
                                    showSheet = true
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black.ignoresSafeArea())
                    .padding(.top, -10)
                }
            }
            .background(.black)
            .sheet(isPresented: $showSheet) {
                AddAlarmView(alarm: $selectedAlarm)
            }
        }
    }
}

#Preview {
    MainView()
}
