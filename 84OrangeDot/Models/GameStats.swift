//
//  GameStats.swift
//  84OrangeDot
//

import Foundation

struct GameStats: Codable {
    var totalGames: Int
    var totalTaps: Int
    var totalMissed: Int
    var bestScore: Int
    var maxCombo: Int
    var bestAccuracyDots: Int // best streak without miss (for Accuracy mode)
    var classicHighScore: Int
    var enduranceHighScore: Int
    var accuracyPerfectRuns: Int
    var chainBestLength: Int
    var lastPlayedDate: Date?
    
    static let empty = GameStats(
        totalGames: 0,
        totalTaps: 0,
        totalMissed: 0,
        bestScore: 0,
        maxCombo: 0,
        bestAccuracyDots: 0,
        classicHighScore: 0,
        enduranceHighScore: 0,
        accuracyPerfectRuns: 0,
        chainBestLength: 0,
        lastPlayedDate: nil
    )
    
    var overallAccuracy: Double {
        let total = totalTaps + totalMissed
        guard total > 0 else { return 0 }
        return Double(totalTaps) / Double(total) * 100
    }
}
