//
//  OnboardingView.swift
//  84OrangeDot
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @State private var currentPage = 0
    
    private let pages: [(title: String, subtitle: String, icon: String)] = [
        ("See orange", "Tap the orange dots before they disappear. Every tap counts.", "circle.fill"),
        ("Stay focused", "Build combos for bonus points. Don't miss — you have 3 lives.", "heart.fill"),
        ("Tap fast", "Choose a mode and beat your best score. Ready?", "play.fill")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPage(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                pageIndicator
                bottomButton
            }
        }
    }
    
    private func onboardingPage(index: Int) -> some View {
        let page = pages[index]
        return VStack(spacing: 32) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 70, weight: .medium))
                .foregroundStyle(Color.orangeGradient)
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.orangeGradient)
                Text(page.subtitle)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.orangeDot : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 24)
    }
    
    private var bottomButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation { currentPage += 1 }
            } else {
                onboardingCompleted = true
                isPresented = false
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orangeGradientVertical)
                )
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
}
