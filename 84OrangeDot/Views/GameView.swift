//
//  GameView.swift
//  84OrangeDot
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [.warmWhite, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                PlayableRectUpdater(geo: geo, viewModel: viewModel)
                
                ForEach(viewModel.dots) { dot in
                    DotView(dot: dot, viewModel: viewModel)
                }
                
                if let pos = viewModel.lastTappedPosition {
                    TapParticlesView(position: pos)
                }
                
                if viewModel.lives == 1 && viewModel.gameMode == .classic {
                    LastLifePulseOverlay()
                }
                
                VStack(spacing: 0) {
                    gameHUD(geo: geo)
                    if viewModel.gameMode == .accuracy || viewModel.gameMode == .chain {
                        modeSubtitle(geo: geo)
                            .padding(.top, 4)
                    }
                    Spacer()
                    if viewModel.combo > 1 {
                        Text("COMBO x\(viewModel.combo)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.orangeGradientVertical)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                    )
                                    .shadow(color: .orangeDot.opacity(0.35), radius: 8, x: 0, y: 4)
                                    .shadow(color: .black.opacity(0.06), radius: 4)
                            )
                            .padding(.bottom, 40)
                    }
                }
                .modifier(ComboShakeModifier(combo: viewModel.combo))
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.gameOver },
            set: { if !$0 { viewModel.gameOver = false } }
        )) {
            GameOverView(viewModel: viewModel) {
                viewModel.gameOver = false
                viewModel.dots.removeAll()
                dismiss()
            }
        }
    }
    
    private func gameHUD(geo: GeometryProxy) -> some View {
        HStack {
            Button {
                viewModel.quitGame()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orangeDot)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Text("\(viewModel.score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.orangeDot)
                .monospacedDigit()
            
            Spacer()
            
            if viewModel.gameMode == .classic || viewModel.lives < 999 {
                HStack(spacing: 6) {
                    ForEach(0..<min(3, viewModel.lives), id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orangeDot)
                    }
                }
            }
            
            Spacer()
            
            if viewModel.gameMode == .classic || viewModel.gameMode == .endurance {
                Text(viewModel.timeString(from: max(0, viewModel.timeRemaining)))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.timeRemaining <= 10 ? .red : .orangeDot)
                    .monospacedDigit()
                    .opacity(1)
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, geo.safeAreaInsets.top + 12)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.95), .warmWhite.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                Rectangle()
                    .fill(Color.orangeDot.opacity(0.03))
                    .frame(height: 1),
                alignment: .bottom
            )
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)
    }
    
    private func modeSubtitle(geo: GeometryProxy) -> some View {
        Group {
            if viewModel.gameMode == .accuracy {
                Text("\(viewModel.accuracyDotsCompleted)/\(viewModel.accuracyDotsGoal)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.orangeGradient)
                    .monospacedDigit()
            } else if viewModel.gameMode == .chain {
                Text("Round \(viewModel.chainRoundLength)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.orangeGradient)
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Combo shake

struct ComboShakeModifier: ViewModifier {
    let combo: Int
    @State private var shakeOffset: CGFloat = 0
    @State private var lastShakeAt: Int = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: combo) { newCombo in
                guard newCombo >= 5, newCombo != lastShakeAt else { return }
                if newCombo == 5 || newCombo == 10 || newCombo == 20 || newCombo == 30 {
                    lastShakeAt = newCombo
                    let amount: CGFloat = newCombo >= 20 ? 6 : 3
                    shakeOffset = amount
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                        shakeOffset = -amount
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.easeOut(duration: 0.05)) { shakeOffset = 0 }
                    }
                }
            }
    }
}

// MARK: - Tap particles

struct TapParticlesView: View {
    let position: CGPoint
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * .pi / 4
                Circle()
                    .fill(Color.orangeDot)
                    .frame(width: 6, height: 6)
                    .offset(x: cos(angle) * 20, y: sin(angle) * 20)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .position(position)
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                scale = 2.5
                opacity = 0
            }
        }
    }
}

// MARK: - Last life pulse

struct LastLifePulseOverlay: View {
    @State private var pulse = false
    var body: some View {
        Rectangle()
            .stroke(Color.red.opacity(pulse ? 0.5 : 0.15), lineWidth: 12)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

struct DotView: View {
    let dot: OrangeDot
    @ObservedObject var viewModel: GameViewModel
    
    @State private var scale: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        let size = dot.size.rawValue
        ZStack {
            if dot.type == .lifeBonus {
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.7))
                    .foregroundColor(.orangeDot)
            } else {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orangeDotLight, .orangeDot, .orangeDotDark],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: size
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(scale * pulseScale)
        .opacity(opacity)
        .position(dot.position)
        .contentShape(Circle())
        .onTapGesture {
            viewModel.tapDot(dot.id)
        }
        .onAppear {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.65)) {
                scale = 1.0
                opacity = 1.0
            }
            if dot.behavior == .pulsing {
                startPulsing()
            }
            if dot.behavior == .fading {
                withAnimation(.linear(duration: max(0.1, dot.lifetime - 0.15))) {
                    opacity = 0
                }
            }
        }
        .onChange(of: dot.state) { newState in
            if newState == .tapped {
                withAnimation(.easeOut(duration: 0.1)) {
                    scale = 1.4
                    opacity = 0
                }
            } else if newState == .disappearing {
                withAnimation(.easeIn(duration: 0.2)) {
                    scale = 0
                    opacity = 0
                }
            }
        }
    }
    
    private func startPulsing() {
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
    }
}

// MARK: - Playable area (safe zone for spawning dots)

private func playableRect(for geo: GeometryProxy) -> CGRect {
    let insets = geo.safeAreaInsets
    let size = geo.size
    let margin: CGFloat = 50
    let topOffset: CGFloat = 70 // below HUD
    let bottomOffset: CGFloat = 50 // above home indicator
    let minX = insets.leading + margin
    let maxX = size.width - insets.trailing - margin
    let minY = insets.top + topOffset
    let maxY = size.height - insets.bottom - bottomOffset
    guard minX < maxX, minY < maxY else { return .zero }
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

private struct PlayableRectUpdater: View {
    let geo: GeometryProxy
    @ObservedObject var viewModel: GameViewModel
    var body: some View {
        Color.clear
            .onAppear {
                viewModel.setScreenBounds(CGRect(origin: .zero, size: geo.size))
                viewModel.setPlayableRect(playableRect(for: geo))
            }
            .onChange(of: geo.size.width) { _, _ in
                viewModel.setScreenBounds(CGRect(origin: .zero, size: geo.size))
                viewModel.setPlayableRect(playableRect(for: geo))
            }
            .onChange(of: geo.size.height) { _, _ in
                viewModel.setScreenBounds(CGRect(origin: .zero, size: geo.size))
                viewModel.setPlayableRect(playableRect(for: geo))
            }
            .onChange(of: geo.safeAreaInsets.top) { _, _ in viewModel.setPlayableRect(playableRect(for: geo)) }
            .onChange(of: geo.safeAreaInsets.bottom) { _, _ in viewModel.setPlayableRect(playableRect(for: geo)) }
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
