//
//  HomeView.swift
//  84OrangeDot
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var storage = AppStorageService.shared
    @State private var dotScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    sloganSection
                    playSection
                    menuGrid
                    Spacer(minLength: 40)
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            GeometryReader { geo in
                let cols = 12
                let rows = 20
                let stepX = geo.size.width / CGFloat(cols)
                let stepY = geo.size.height / CGFloat(rows)
                Canvas { context, size in
                    for row in 0..<rows {
                        for col in 0..<cols {
                            let x = CGFloat(col) * stepX + stepX / 2
                            let y = CGFloat(row) * stepY + stepY / 2
                            context.fill(
                                Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)),
                                with: .color(Color.orangeDot.opacity(0.07))
                            )
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orangeDot.opacity(glowOpacity), .orangeDot.opacity(glowOpacity * 0.5), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.orangeGradientVertical)
                    .frame(width: 120, height: 120)
                    .scaleEffect(dotScale)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            .scaleEffect(dotScale)
                    )
                    .shadow(color: .orangeDot.opacity(0.5), radius: 20, x: 0, y: 10)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            }
            .padding(.top, 50)
            
            Text("ORANGE DOT")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(Color.orangeGradient)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                dotScale = 1.08
                glowOpacity = 0.5
            }
        }
    }
    
    private var sloganSection: some View {
        Text("See orange. Tap fast.")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(.gray.opacity(0.9))
            .padding(.top, 8)
    }
    
    // MARK: - Play CTA
    
    private var playSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: ClassicGameDestination()) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 22))
                    Text("PLAY")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(1.2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.orangeGradientVertical)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.orangeDot.opacity(0.4), radius: 14, x: 0, y: 8)
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.top, 36)
            
            if storage.stats.bestScore > 0 {
                Text("Best: \(storage.stats.bestScore)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .monospacedDigit()
            }
        }
    }
    
    // MARK: - Menu grid
    
    private var menuGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            menuTile("MODES", icon: "square.grid.2x2", destination: ModesView())
            menuTile("DAILY", icon: "calendar", destination: DailyChallengeView())
            menuTile("RECORDS", icon: "trophy", destination: RecordsView())
            menuTile("STATS", icon: "chart.bar", destination: StatsView())
            menuTile("ACHIEVE", icon: "star", destination: AchievementsView())
            menuTile("SETTINGS", icon: "gearshape", destination: SettingsView())
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    private func menuTile<D: View>(_ title: String, icon: String, destination: D) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.orangeGradient)
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.orangeDot.opacity(0.25), .orangeDot.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
                    .shadow(color: .orangeDot.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
