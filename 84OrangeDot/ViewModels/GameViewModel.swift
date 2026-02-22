//
//  GameViewModel.swift
//  84OrangeDot
//

import SwiftUI
import Combine
import UIKit

enum GameMode: String, CaseIterable {
    case classic = "Classic"
    case endurance = "Endurance"
    case accuracy = "Accuracy"
    case chain = "Chain"
    case zen = "Zen"
    
    var description: String {
        switch self {
        case .classic: return "60 sec, 3 lives"
        case .endurance: return "No timer, one miss = game over"
        case .accuracy: return "30 dots, no mistakes"
        case .chain: return "Repeat the sequence"
        case .zen: return "Relax, no pressure"
        }
    }
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var timeRemaining: TimeInterval = 60
    @Published var combo: Int = 0
    @Published var dots: [OrangeDot] = []
    @Published var isActive: Bool = false
    @Published var gameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var highScoreBeaten: Bool = false
    @Published var lastTappedPosition: CGPoint? = nil
    @Published var accuracyDotsCompleted: Int = 0
    @Published var accuracyWon: Bool = false
    @Published var chainDotsInRound: Int = 0
    @Published var chainRoundLength: Int = 3
    
    var gameMode: GameMode = .classic
    var screenBounds: CGRect = .zero
    var playableRect: CGRect = .zero
    
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private let maxDotsOnScreen = 5
    let accuracyDotsGoal = 30
    private var totalTapped: Int = 0
    private var totalMissed: Int = 0
    private var currentAccuracyStreak: Int = 0
    private var maxAccuracyStreakThisGame: Int = 0
    private var chainBestLengthThisGame: Int = 0
    private var maxComboThisGame: Int = 0
    private var scoreMultiplierEndTime: Date?
    private var slowMotionEndTime: Date?
    
    var accuracy: Double {
        let total = totalTapped + totalMissed
        guard total > 0 else { return 1.0 }
        return Double(totalTapped) / Double(total)
    }
    
    var comboMultiplier: Double {
        min(50, 1.0 + Double(combo) * 0.1)
    }
    
    func setScreenBounds(_ bounds: CGRect) {
        screenBounds = bounds
    }
    
    func setPlayableRect(_ rect: CGRect) {
        playableRect = rect
    }
    
    func startGame(mode: GameMode = .classic) {
        gameMode = mode
        isActive = true
        gameOver = false
        highScoreBeaten = false
        accuracyWon = false
        score = 0
        totalTapped = 0
        totalMissed = 0
        currentAccuracyStreak = 0
        maxAccuracyStreakThisGame = 0
        chainBestLengthThisGame = 0
        maxComboThisGame = 0
        scoreMultiplierEndTime = nil
        slowMotionEndTime = nil
        
        switch mode {
        case .classic:
            lives = 3
            timeRemaining = 60
            accuracyDotsCompleted = 0
            chainDotsInRound = 0
            chainRoundLength = 3
        case .endurance:
            lives = 1
            timeRemaining = 60
        case .accuracy:
            lives = 1
            timeRemaining = 999
            accuracyDotsCompleted = 0
        case .chain:
            lives = 1
            timeRemaining = 999
            chainDotsInRound = 0
            chainRoundLength = 3
        case .zen:
            lives = 999
            timeRemaining = 999
        }
        
        combo = 0
        dots.removeAll()
        
        startGameTimer()
        startSpawning()
    }
    
    private func startGameTimer() {
        let interval: TimeInterval
        if slowMotionEndTime != nil {
            interval = 0.2
        } else {
            interval = 0.1
        }
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        gameTimer?.tolerance = 0.02
        RunLoop.main.add(gameTimer!, forMode: .common)
    }
    
    private func tick() {
        guard isActive, !isPaused else { return }
        
        if gameMode == .classic || gameMode == .endurance {
            let delta = slowMotionEndTime.map { Date() < $0 } == true ? 0.05 : 0.1
            timeRemaining -= delta
            if timeRemaining <= 0 {
                endGame()
                return
            }
        }
        
        updateDots()
    }
    
    private func startSpawning() {
        spawnTimer?.invalidate()
        let interval = calculateSpawnInterval()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.spawnDot()
            }
        }
        spawnTimer?.tolerance = 0.1
        RunLoop.main.add(spawnTimer!, forMode: .common)
        spawnDot()
    }
    
    private func rescheduleSpawn() {
        spawnTimer?.invalidate()
        let interval = calculateSpawnInterval()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.spawnDot()
            }
        }
        spawnTimer?.tolerance = 0.1
        RunLoop.main.add(spawnTimer!, forMode: .common)
    }
    
    private func calculateSpawnInterval() -> TimeInterval {
        if gameMode == .zen { return 1.4 }
        let base: TimeInterval = 1.0
        let scoreFactor = min(Double(score) / 1000.0, 2.0)
        return max(0.35, base - (scoreFactor * 0.35))
    }
    
    private func spawnDot() {
        if gameMode == .accuracy {
            guard dots.isEmpty, accuracyDotsCompleted < accuracyDotsGoal else { return }
        } else if gameMode == .chain {
            guard dots.isEmpty, chainDotsInRound < chainRoundLength else { return }
        } else {
            guard dots.count < maxDotsOnScreen else { return }
        }
        guard isActive, !isPaused else { return }
        let r = playableRect
        guard r.width > 40, r.height > 40 else { return }
        
        let margin: CGFloat = 40
        let position = CGPoint(
            x: CGFloat.random(in: (r.minX + margin)...(r.maxX - margin)),
            y: CGFloat.random(in: (r.minY + margin)...(r.maxY - margin))
        )
        
        let size = chooseSize()
        let lifetime = size.displayTime * timeScaleForDifficulty()
        
        var movement: OrangeDot.DotMovement? = nil
        var behavior: OrangeDot.DotBehavior = .static
        if gameMode == .zen {
            if Double.random(in: 0...1) < 0.25 { behavior = .fading }
        } else if gameMode != .accuracy && gameMode != .chain {
            if score > 200 && Double.random(in: 0...1) < 0.3 {
                behavior = .moving
                let angle = CGFloat.random(in: 0...(2 * .pi))
                let speed = CGFloat.random(in: 80...180)
                movement = OrangeDot.DotMovement(
                    velocity: CGPoint(x: cos(angle) * speed, y: sin(angle) * speed),
                    direction: angle
                )
            } else if score > 500 && Double.random(in: 0...1) < 0.2 {
                behavior = .pulsing
            } else if score > 300 && Double.random(in: 0...1) < 0.15 {
                behavior = .fading
            } else if score > 400 && Double.random(in: 0...1) < 0.1 {
                behavior = .splitting
            }
        }
        
        let type: OrangeDot.DotType
        if gameMode == .classic && Double.random(in: 0...1) < 0.03 {
            type = .lifeBonus
        } else if gameMode != .accuracy && gameMode != .chain && Double.random(in: 0...1) < 0.02 {
            type = .scoreBonus
        } else if gameMode != .accuracy && gameMode != .chain && Double.random(in: 0...1) < 0.02 {
            type = .timeBonus
        } else {
            type = .regular
        }
        
        let dot = OrangeDot(
            type: type,
            position: position,
            size: size,
            appearanceTime: Date(),
            lifetime: lifetime,
            state: .appearing,
            movement: movement,
            behavior: behavior
        )
        dots.append(dot)
        if gameMode != .accuracy && gameMode != .chain {
            rescheduleSpawn()
        }
    }
    
    private func chooseSize() -> OrangeDot.DotSize {
        if gameMode == .zen { return .large }
        if gameMode == .accuracy || gameMode == .chain {
            return [.medium, .large].randomElement()!
        }
        let scoreThreshold = Double(score)
        if scoreThreshold > 2000 {
            return [.tiny, .small, .medium, .large].randomElement()!
        } else if scoreThreshold > 500 {
            return [.small, .medium, .large].randomElement()!
        } else if scoreThreshold > 100 {
            return [.medium, .large].randomElement()!
        } else {
            return .large
        }
    }
    
    private func timeScaleForDifficulty() -> Double {
        let d = min(1.0, Double(score) / 5000.0)
        if accuracy > 0.9 { return max(0.5, 1.0 - d * 0.6) }
        if accuracy < 0.7 { return min(1.2, 1.0 + 0.3) }
        return max(0.6, 1.0 - d * 0.4)
    }
    
    func tapDot(_ dotID: UUID) {
        guard let index = dots.firstIndex(where: { $0.id == dotID }),
              dots[index].state == .visible else { return }
        
        let position = dots[index].position
        dots[index].state = .tapped
        totalTapped += 1
        currentAccuracyStreak += 1
        maxAccuracyStreakThisGame = max(maxAccuracyStreakThisGame, currentAccuracyStreak)
        lastTappedPosition = position
        
        var basePoints = dots[index].size.points
        if dots[index].type == .scoreBonus {
            scoreMultiplierEndTime = Date().addingTimeInterval(10)
        }
        if dots[index].type == .timeBonus {
            slowMotionEndTime = Date().addingTimeInterval(5)
        }
        if dots[index].type == .lifeBonus && gameMode == .classic {
            lives = min(3, lives + 1)
        }
        
        let mult = (scoreMultiplierEndTime.map { Date() < $0 } == true) ? 2.0 : 1.0
        let pointsEarned = Int(Double(basePoints) * comboMultiplier * mult)
        score += pointsEarned
        combo += 1
        maxComboThisGame = max(maxComboThisGame, combo)
        
        if gameMode == .accuracy {
            accuracyDotsCompleted += 1
            if accuracyDotsCompleted >= accuracyDotsGoal {
                accuracyWon = true
                endGame()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.dots.removeAll { $0.id == dotID }
                self?.lastTappedPosition = nil
                self?.spawnDot()
            }
            hapticFeedback(.success)
            return
        }
        
        if gameMode == .chain {
            chainDotsInRound += 1
            let roundComplete = chainDotsInRound >= chainRoundLength
            if roundComplete {
                chainBestLengthThisGame = max(chainBestLengthThisGame, chainRoundLength)
                chainDotsInRound = 0
                chainRoundLength += 1
                score += 50
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.dots.removeAll { $0.id == dotID }
                self?.lastTappedPosition = nil
                self?.spawnDot()
            }
            hapticFeedback(.success)
            return
        }
        
        hapticFeedback(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.dots.removeAll { $0.id == dotID }
            self?.lastTappedPosition = nil
        }
    }
    
    private func updateDots() {
        let now = Date()
        let delta = 0.1
        
        for i in dots.indices.reversed() {
            let elapsed = now.timeIntervalSince(dots[i].appearanceTime)
            
            if dots[i].state == .appearing && elapsed >= 0.1 {
                dots[i].state = .visible
            }
            
            if dots[i].state == .visible && elapsed >= dots[i].lifetime {
                dots[i].state = .disappearing
                missDot()
                let id = dots[i].id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.dots.removeAll { $0.id == id }
                }
            }
            
            if let movement = dots[i].movement, dots[i].state == .visible {
                var vel = movement.velocity
                let r = playableRect
                if r.isEmpty == false {
                    let margin: CGFloat = 30
                    if dots[i].position.x <= r.minX + margin || dots[i].position.x >= r.maxX - margin { vel.x *= -1 }
                    if dots[i].position.y <= r.minY + margin || dots[i].position.y >= r.maxY - margin { vel.y *= -1 }
                }
                dots[i].position.x += vel.x * delta
                dots[i].position.y += vel.y * delta
                dots[i].movement = OrangeDot.DotMovement(velocity: vel, direction: movement.direction)
            }
        }
    }
    
    private func missDot() {
        totalMissed += 1
        currentAccuracyStreak = 0
        combo = 0
        lives -= 1
        hapticFeedback(.error)
        if lives <= 0 {
            endGame()
        }
    }
    
    func endGame() {
        isActive = false
        gameOver = true
        gameTimer?.invalidate()
        gameTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
        
        let high = UserDefaults.standard.integer(forKey: "highScore")
        if score > high {
            UserDefaults.standard.set(score, forKey: "highScore")
            highScoreBeaten = true
        }
        recordSessionToStorage()
    }
    
    /// Quit to menu without showing game over. Saves high score if beaten.
    func quitGame() {
        isActive = false
        gameOver = false
        gameTimer?.invalidate()
        gameTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
        dots.removeAll()
        let high = UserDefaults.standard.integer(forKey: "highScore")
        if score > high {
            UserDefaults.standard.set(score, forKey: "highScore")
        }
        recordSessionToStorage()
    }
    
    private func recordSessionToStorage() {
        guard totalTapped + totalMissed > 0 else { return }
        AppStorageService.shared.recordGameResult(
            score: score,
            taps: totalTapped,
            missed: totalMissed,
            maxCombo: maxComboThisGame,
            mode: gameMode,
            accuracyDotsStreak: maxAccuracyStreakThisGame,
            accuracyPerfect: accuracyWon,
            chainLength: gameMode == .chain ? chainBestLengthThisGame : 0
        )
    }
    
    private func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(type)
    }
    
    func timeString(from seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
