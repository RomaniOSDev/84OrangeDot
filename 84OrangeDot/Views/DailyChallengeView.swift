//
//  DailyChallengeView.swift
//  84OrangeDot
//

import SwiftUI

struct DailyChallengeView: View {
    @ObservedObject var storage = AppStorageService.shared
    
    private var challenge: DailyChallengeState? {
        storage.dailyChallenge
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Text("DAILY CHALLENGE")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.orangeGradient)
                    .padding(.top, 20)
                
                if let c = challenge {
                    VStack(spacing: 20) {
                        Image(systemName: c.challengeKind.iconName)
                            .font(.system(size: 56))
                            .foregroundStyle(c.completed ? Color.orangeGradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                        
                        Text(c.challengeKind.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(c.challengeKind.description)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if c.completed {
                            Label("Completed!", systemImage: "checkmark.seal.fill")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.orangeGradient)
                        } else {
                            if c.challengeKind == .play3games {
                                Text("Games today: \(c.gamesPlayedToday)/3")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.orangeGradient)
                            }
                        }
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.orangeDot.opacity(0.3), .orangeDot.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .orangeDot.opacity(0.12), radius: 20, x: 0, y: 10)
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 24)
                } else {
                    Text("No challenge today")
                        .foregroundColor(.gray)
                }
                
                Text("Complete the challenge in any game mode.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
