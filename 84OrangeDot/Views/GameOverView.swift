//
//  GameOverView.swift
//  84OrangeDot
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    var onDismiss: () -> Void
    
    private var highScore: Int {
        UserDefaults.standard.integer(forKey: "highScore")
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                if viewModel.accuracyWon {
                    Text("PERFECT!")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                    Text("30/30 Accuracy")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                } else {
                    Text("GAME OVER")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                }
                
                if viewModel.highScoreBeaten {
                    Text("NEW HIGH SCORE!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                }
                
                VStack(spacing: 12) {
                    Text("Score")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    Text("\(viewModel.score)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                        .monospacedDigit()
                    
                    if highScore > 0 && !viewModel.highScoreBeaten {
                        Text("Best: \(highScore)")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                            .monospacedDigit()
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.cardGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.orangeDot.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .orangeDot.opacity(0.1), radius: 16, x: 0, y: 8)
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                )
                
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.startGame(mode: viewModel.gameMode)
                        onDismiss()
                    }) {
                        Text("PLAY AGAIN")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orangeGradientVertical)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .orangeDot.opacity(0.4), radius: 10, x: 0, y: 5)
                                    .shadow(color: .black.opacity(0.06), radius: 4)
                            )
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: onDismiss) {
                        Text("MAIN MENU")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.orangeGradient)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}
