//
//  AppStorageService.swift
//  84OrangeDot
//

import Foundation
import SwiftUI
import Combine

final class AppStorageService: ObservableObject {
    static let shared = AppStorageService()
    
    private let defaults = UserDefaults.standard
    private let statsKey = "gameStats"
    private let achievementsKey = "unlockedAchievementIds"
    private let dailyKey = "dailyChallengeState"
    private let highScoreKey = "highScore"
    
    @Published var stats: GameStats
    @Published var unlockedAchievementIds: Set<String>
    @Published var dailyChallenge: DailyChallengeState?
    
    init() {
        self.stats = (try? defaults.decode(GameStats.self, forKey: statsKey)).flatMap { $0 } ?? .empty
        let ids = defaults.stringArray(forKey: achievementsKey) ?? []
        self.unlockedAchievementIds = Set(ids)
        self.dailyChallenge = (try? defaults.decode(DailyChallengeState.self, forKey: dailyKey)).flatMap { $0 }
        refreshDailyIfNeeded()
    }
    
    var highScore: Int {
        get { defaults.integer(forKey: highScoreKey) }
        set { defaults.set(newValue, forKey: highScoreKey) }
    }
    
    func saveStats(_ newStats: GameStats) {
        stats = newStats
        try? defaults.encode(stats, forKey: statsKey)
    }
    
    func recordGameResult(
        score: Int,
        taps: Int,
        missed: Int,
        maxCombo: Int,
        mode: GameMode,
        accuracyDotsStreak: Int,
        accuracyPerfect: Bool,
        chainLength: Int
    ) {
        var s = stats
        s.totalGames += 1
        s.totalTaps += taps
        s.totalMissed += missed
        s.bestScore = max(s.bestScore, score)
        s.maxCombo = max(s.maxCombo, maxCombo)
        s.bestAccuracyDots = max(s.bestAccuracyDots, accuracyDotsStreak)
        s.lastPlayedDate = Date()
        
        switch mode {
        case .classic:
            s.classicHighScore = max(s.classicHighScore, score)
        case .endurance:
            s.enduranceHighScore = max(s.enduranceHighScore, score)
        case .accuracy:
            if accuracyPerfect { s.accuracyPerfectRuns += 1 }
        case .chain:
            s.chainBestLength = max(s.chainBestLength, chainLength)
        case .zen:
            break
        }
        
        saveStats(s)
        checkAchievements(stats: s)
        updateDailyChallenge(
            score: score,
            maxCombo: maxCombo,
            accuracyPerfect: accuracyPerfect,
            accuracyStreak: accuracyDotsStreak,
            gamePlayed: true
        )
    }
    
    private func checkAchievements(stats: GameStats) {
        for a in Achievement.all {
            if !unlockedAchievementIds.contains(a.id), a.requirement(stats) {
                unlockedAchievementIds.insert(a.id)
                defaults.set(Array(unlockedAchievementIds), forKey: achievementsKey)
            }
        }
    }
    
    private func refreshDailyIfNeeded() {
        let today = dayString(from: Date())
        if dailyChallenge == nil || dailyChallenge!.dateString != today {
            let kind = DailyChallengeKind.allCases.randomElement()!
            dailyChallenge = DailyChallengeState(
                dateString: today,
                challengeKind: kind,
                completed: false,
                gamesPlayedToday: 0
            )
            try? defaults.encode(dailyChallenge, forKey: dailyKey)
        }
    }
    
    private func dayString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone.current
        return f.string(from: date)
    }
    
    private func updateDailyChallenge(
        score: Int,
        maxCombo: Int,
        accuracyPerfect: Bool,
        accuracyStreak: Int,
        gamePlayed: Bool
    ) {
        refreshDailyIfNeeded()
        guard var d = dailyChallenge, !d.completed else { return }
        
        if gamePlayed { d.gamesPlayedToday += 1 }
        
        switch d.challengeKind {
        case .score500: if score >= 500 { d.completed = true }
        case .score1000: if score >= 1000 { d.completed = true }
        case .combo10: if maxCombo >= 10 { d.completed = true }
        case .play3games: if d.gamesPlayedToday >= 3 { d.completed = true }
        case .accuracyPerfect: if accuracyPerfect { d.completed = true }
        case .noMiss10: if accuracyStreak >= 10 { d.completed = true }
        }
        
        dailyChallenge = d
        try? defaults.encode(dailyChallenge, forKey: dailyKey)
    }
}

// MARK: - UserDefaults Codable helpers

extension UserDefaults {
    func encode<T: Encodable>(_ value: T, forKey key: String) throws {
        set(try JSONEncoder().encode(value), forKey: key)
    }
    func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
