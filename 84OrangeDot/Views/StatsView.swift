//
//  StatsView.swift
//  84OrangeDot
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var storage = AppStorageService.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("STATISTICS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                        .padding(.top, 20)
                    
                    let s = storage.stats
                    VStack(spacing: 16) {
                        statRow(title: "Games Played", value: "\(s.totalGames)")
                        statRow(title: "Total Taps", value: "\(s.totalTaps)")
                        statRow(title: "Total Missed", value: "\(s.totalMissed)")
                        statRow(title: "Accuracy", value: String(format: "%.1f%%", s.overallAccuracy))
                        statRow(title: "Best Score", value: "\(s.bestScore)")
                        statRow(title: "Max Combo", value: "\(s.maxCombo)x")
                        statRow(title: "Best Streak (no miss)", value: "\(s.bestAccuracyDots)")
                        statRow(title: "Classic High Score", value: "\(s.classicHighScore)")
                        statRow(title: "Endurance High Score", value: "\(s.enduranceHighScore)")
                        statRow(title: "Perfect Accuracy Runs", value: "\(s.accuracyPerfectRuns)")
                        statRow(title: "Best Chain Length", value: "\(s.chainBestLength)")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.cardGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.orangeDot.opacity(0.12), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .shadow(color: .orangeDot.opacity(0.04), radius: 6, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.orangeGradient)
                .monospacedDigit()
        }
        .padding(.vertical, 6)
    }
}
