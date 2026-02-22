//
//  RecordsView.swift
//  84OrangeDot
//

import SwiftUI

struct RecordsView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var highScore: Int {
        UserDefaults.standard.integer(forKey: "highScore")
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("RECORDS")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.orangeGradient)
                    .padding(.top, 20)
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orangeDot.opacity(0.2), .orangeDot.opacity(0.06), .clear],
                                center: .center,
                                startRadius: 40,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                    Circle()
                        .fill(Color.cardGradient)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.orangeDot.opacity(0.3), .orangeDot.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .orangeDot.opacity(0.12), radius: 20, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 12) {
                        Text("Best Score")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        Text("\(highScore)")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(Color.orangeGradient)
                            .monospacedDigit()
                    }
                }
                .padding(40)
                
                Text("See orange. Tap fast.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .italic()
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
