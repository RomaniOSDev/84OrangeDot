//
//  DailyChallenge.swift
//  84OrangeDot
//

import Foundation

enum DailyChallengeKind: String, Codable, CaseIterable {
    case score500 = "score_500"
    case score1000 = "score_1000"
    case combo10 = "combo_10"
    case play3games = "play_3_games"
    case accuracyPerfect = "accuracy_perfect"
    case noMiss10 = "no_miss_10"
    
    var title: String {
        switch self {
        case .score500: return "Score 500"
        case .score1000: return "Score 1000"
        case .combo10: return "Reach 10x Combo"
        case .play3games: return "Play 3 Games"
        case .accuracyPerfect: return "Perfect Accuracy (30/30)"
        case .noMiss10: return "10 Dots Without Miss"
        }
    }
    
    var description: String {
        switch self {
        case .score500: return "Score at least 500 in one game"
        case .score1000: return "Score at least 1000 in one game"
        case .combo10: return "Get a 10x combo in one game"
        case .play3games: return "Complete 3 games today"
        case .accuracyPerfect: return "Complete Accuracy mode with 30/30"
        case .noMiss10: return "Tap 10 dots in a row without missing"
        }
    }
    
    var iconName: String {
        switch self {
        case .score500, .score1000: return "star.fill"
        case .combo10: return "flame.fill"
        case .play3games: return "gamecontroller.fill"
        case .accuracyPerfect: return "checkmark.seal.fill"
        case .noMiss10: return "scope"
        }
    }
}

struct DailyChallengeState: Codable {
    var dateString: String // "yyyy-MM-dd"
    var challengeKind: DailyChallengeKind
    var completed: Bool
    var gamesPlayedToday: Int
}
