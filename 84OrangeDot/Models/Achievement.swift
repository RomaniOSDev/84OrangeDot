//
//  Achievement.swift
//  84OrangeDot
//

import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let requirement: (GameStats) -> Bool
    
    static let all: [Achievement] = [
        Achievement(
            id: "first_tap",
            title: "First Tap",
            description: "Tap your first dot",
            iconName: "hand.tap.fill",
            requirement: { $0.totalTaps >= 1 }
        ),
        Achievement(
            id: "score_100",
            title: "Century",
            description: "Score 100 points in one game",
            iconName: "flame.fill",
            requirement: { $0.bestScore >= 100 }
        ),
        Achievement(
            id: "score_500",
            title: "Half Grand",
            description: "Score 500 points in one game",
            iconName: "star.fill",
            requirement: { $0.bestScore >= 500 }
        ),
        Achievement(
            id: "score_1000",
            title: "Grand",
            description: "Score 1000 points in one game",
            iconName: "crown.fill",
            requirement: { $0.bestScore >= 1000 }
        ),
        Achievement(
            id: "combo_5",
            title: "Combo 5",
            description: "Reach a 5x combo",
            iconName: "5.circle.fill",
            requirement: { $0.maxCombo >= 5 }
        ),
        Achievement(
            id: "combo_10",
            title: "Combo 10",
            description: "Reach a 10x combo",
            iconName: "10.circle.fill",
            requirement: { $0.maxCombo >= 10 }
        ),
        Achievement(
            id: "combo_20",
            title: "On Fire",
            description: "Reach a 20x combo",
            iconName: "flame.circle.fill",
            requirement: { $0.maxCombo >= 20 }
        ),
        Achievement(
            id: "accuracy_10",
            title: "Steady Hand",
            description: "Tap 10 dots without a miss",
            iconName: "scope",
            requirement: { $0.bestAccuracyDots >= 10 }
        ),
        Achievement(
            id: "accuracy_30",
            title: "Perfect Run",
            description: "Complete Accuracy mode (30/30)",
            iconName: "checkmark.seal.fill",
            requirement: { $0.accuracyPerfectRuns >= 1 }
        ),
        Achievement(
            id: "chain_5",
            title: "Memory",
            description: "Complete a chain of 5",
            iconName: "brain.head.profile",
            requirement: { $0.chainBestLength >= 5 }
        ),
        Achievement(
            id: "games_10",
            title: "Dedicated",
            description: "Play 10 games",
            iconName: "gamecontroller.fill",
            requirement: { $0.totalGames >= 10 }
        ),
        Achievement(
            id: "games_50",
            title: "Addicted",
            description: "Play 50 games",
            iconName: "heart.circle.fill",
            requirement: { $0.totalGames >= 50 }
        )
    ]
}
