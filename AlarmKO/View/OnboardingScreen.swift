//
//  SwiftUIView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 19/05/25.
//

import SwiftUI
import UserNotifications

struct OnboardingScreen: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.scenePhase) var scenePhase
    @Binding var hasSeenOnboarding: Bool
    @State private var activeOnBoarding: OnBoarding = onBoardingScreens[0]
    
    private var isNotificationScreen: Bool {
        if let index = onBoardingScreens.firstIndex(of: activeOnBoarding) {
            return index == 2
        }
        return false
    }

    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Spacer(minLength: 0)
            
            if isNotificationScreen {
                VStack(alignment: .center, spacing: 50) {
                    Text(activeOnBoarding.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    if notificationManager.isGranted {
                        Image("Allow Notification Icon")
                    }
                    
                    Text(activeOnBoarding.subtitle)
                        .multilineTextAlignment(.center)
                }
                .vSpacing(.center)
                .task {
                    try? await notificationManager.requestAuthorization()
                }
                
                Spacer(minLength: 0)
                
                Button {
                    if notificationManager.isGranted {
                        changeOnBoarding()
                    } else {
                        notificationManager.openSettings()
                    }
                } label: {
                    Text(notificationManager.isGranted ? "Continue" : "Enable Notifications")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.black)
                .tint(Color.prim)
            } else {
                VStack(alignment: .leading, spacing: 15) {
                    Text(activeOnBoarding.title)
                        .font(.largeTitle.bold())
                    
                    Text(activeOnBoarding.subtitle)
                }
                .hSpacing(.leading)
                
                Button {
                    changeOnBoarding()
                } label: {
                    Text("Continue")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.black)
                .tint(Color.prim)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if activeOnBoarding.onBoardingBackground == "OnBoarding 3" {
                Color.black
            } else {
                ZStack {
                    Image(activeOnBoarding.onBoardingBackground)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    LinearGradient(colors: [Color.black.opacity(0.8), Color.clear], startPoint: .bottom, endPoint: .center)
                        .ignoresSafeArea()
                }
            }
        }
        .overlay(alignment: .topLeading) {
            if activeOnBoarding != onBoardingScreens.first {
                Button {
                    changeOnBoarding(true)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        
                        Text("Back")
                    }
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                Task {
                    await notificationManager.getCurrentSettings()
                }
            }
        }
    }
    
    private func changeOnBoarding(_ isPrevious: Bool = false) {
        if let index = onBoardingScreens.firstIndex(of: activeOnBoarding), (isPrevious ? index != 0 : index != onBoardingScreens.count - 1) {
            activeOnBoarding = isPrevious ? onBoardingScreens[index - 1] : onBoardingScreens[index + 1]
        } else {
            activeOnBoarding = isPrevious ? onBoardingScreens[0] : onBoardingScreens[onBoardingScreens.count - 1]
            if activeOnBoarding == onBoardingScreens[onBoardingScreens.count - 1] {
                hasSeenOnboarding = true
            }
        }
    }
}

#Preview {
    OnboardingScreen(hasSeenOnboarding: .constant(false))
        .preferredColorScheme(.dark)
        .environmentObject(NotificationManager())
}
