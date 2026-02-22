//
//  ModesView.swift
//  84OrangeDot
//

import SwiftUI

struct ModesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("GAME MODES")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                        .padding(.top, 20)
                    
                    ForEach(GameMode.allCases, id: \.rawValue) { mode in
                        NavigationLink(destination: GameModeDestination(mode: mode)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(mode.rawValue)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.orangeGradient)
                                Text(mode.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.cardGradient)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.orangeDot.opacity(0.35), .orangeDot.opacity(0.12)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
                                    .shadow(color: .orangeDot.opacity(0.05), radius: 6, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                    }
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GameModeDestination: View {
    let mode: GameMode
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GameView(viewModel: viewModel)
            .onAppear {
                if !viewModel.isActive && !viewModel.gameOver {
                    viewModel.startGame(mode: mode)
                }
            }
    }
}
