//
//  ContentView.swift
//  84OrangeDot
//
//  Created by Роман Главацкий on 07.02.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !onboardingCompleted },
            set: { if !$0 { onboardingCompleted = true } }
        )) {
            OnboardingView(isPresented: Binding(
                get: { false },
                set: { if !$0 { onboardingCompleted = true } }
            ))
        }
    }
}

struct ClassicGameDestination: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GameView(viewModel: viewModel)
            .onAppear {
                if !viewModel.isActive && !viewModel.gameOver {
                    viewModel.startGame(mode: .classic)
                }
            }
    }
}

struct MenuButton: View {
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.orangeDot)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ContentView()
}
