//
//  SwiftUIView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 19/05/25.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int = 0
    let title: String
    let subtitle: String
    let image: String
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State var currentPage: Int = 0
    
    let onboardingPages = [
        OnboardingPage(title: "Welcome to punching alarm", subtitle: "Normal alarms can’t wake you up? \nSnooze buttons too easy ? ", image: "onboarding1"),
        OnboardingPage(title: "Punch to wake \nNo excuses", subtitle: "This alarm won’t stop by tapping. \nPunch it till it gives up.", image: "onboarding2"),
        OnboardingPage(title: "Allow \nNotifications", subtitle: "If notifications are turned off, you won’t see or hear anything when alarms ring.", image: "icon_allow_notif"),
        OnboardingPage(title: "Sound On = Mission On", subtitle: "To win the battle,\nkeep your silent switch off.\nNo sound, no challenge!", image: "onboarding4")
    ]

    var body: some View {
        ZStack {
            if (currentPage == 2) {
                Color(.black)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Image("\(onboardingPages[currentPage].image)")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack() {
                Spacer()
                Image("onboarding_gradient")
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack() {
                if (currentPage != 0) {
                    HStack {
                        Button(action: {
                            if currentPage > 0 {
                                currentPage -= 1
                            }
                        }) {
                            Label("Back", systemImage: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .regular))
                        }
                        .padding(.leading, currentPage == 1 ? 90 : 31 )
                        .padding(.top, currentPage == 3 ? 64 : 18)
                        
                        Spacer()
                    }
                }
                
                if (currentPage == 2) {
                        Text("\(onboardingPages[currentPage].title)")
                            .foregroundColor(.white)
                            .font(.system(size: 36, weight: .bold))
                            .padding(.top, 126)
                            .multilineTextAlignment(.center)
                        
                        Image("\(onboardingPages[currentPage].image)")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 156)
                            .padding(.top, 52)
                        
                        Text("\(onboardingPages[currentPage].subtitle)")
                            .foregroundColor(.white)
                            .font(Font.custom("SF Pro", size: 16).weight(.light))
                            .frame(width: 317, height: 55, alignment: .top)
                            .padding(.top, 74)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                } else {
                        Spacer()
                        
                        Text("\(onboardingPages[currentPage].title)")
                            .foregroundColor(.white)
                            .font(.system(size: currentPage == 3 ? 24 : 36, weight: .bold))
                            .frame(maxWidth: currentPage == 3 ? .infinity : 334, alignment: .leading)
                            .padding(.leading, currentPage == 3 ? 30 : 0)
                        
                        Text("\(onboardingPages[currentPage].subtitle)")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .light))
                            .padding(.top, 8)
                            .frame(maxWidth: currentPage == 3 ? .infinity : 334, alignment: .leading)
                            .padding(.leading, currentPage == 3 ? 30 : 0)
                }
                
                Button(action: {
                    if currentPage < onboardingPages.count - 1 {
                            currentPage += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                }) {
                    Text("Continue")
                        .frame(width: 334, height: 46)
                        .font(.system(size: 17, weight: .bold))
                }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .buttonBorderShape(.automatic)
                    .foregroundColor(.black)
                    .tint(Color(0xDBF173))
                    .padding(.top, 20)
                    .padding(.bottom, currentPage == 3 ? 81 : 35)
            }
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
