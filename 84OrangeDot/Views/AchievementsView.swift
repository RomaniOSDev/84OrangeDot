//
//  AchievementsView.swift
//  84OrangeDot
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var storage = AppStorageService.shared
    
    var body: some View {
        ZStack {
            achievementsBackground
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    achievementsHeader
                    ForEach(Achievement.all, id: \.id) { a in
                        AchievementRowView(
                            achievement: a,
                            unlocked: storage.unlockedAchievementIds.contains(a.id)
                        )
                    }
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var achievementsBackground: some View {
        LinearGradient(
            colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var achievementsHeader: some View {
        VStack(spacing: 8) {
            Text("ACHIEVEMENTS")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Color.orangeGradient)
                .padding(.top, 20)
            Text("\(storage.unlockedAchievementIds.count)/\(Achievement.all.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

private struct AchievementRowView: View {
    let achievement: Achievement
    let unlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 28))
                .foregroundColor(unlocked ? .orangeDot : .gray.opacity(0.5))
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(unlocked ? .primary : .gray)
                Text(achievement.description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            if unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.orangeGradient)
            }
        }
        .padding(16)
        .background(achievementRowBackground)
        .padding(.horizontal, 24)
    }
    
    private var achievementRowBackground: some View {
        let fillStyle: LinearGradient = unlocked
            ? Color.cardGradient
            : LinearGradient(
                colors: [.white.opacity(0.9), Color.warmWhite.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        return RoundedRectangle(cornerRadius: 18)
            .fill(fillStyle)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        unlocked ? Color.orangeDot.opacity(0.25) : Color.gray.opacity(0.15),
                        lineWidth: 1
                    )
            )
            .shadow(color: unlocked ? .orangeDot.opacity(0.08) : .clear, radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
