//
//  SettingsView.swift
//  84OrangeDot
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmWhite, .white, Color.warmGray.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("SETTINGS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangeGradient)
                        .padding(.top, 20)
                    
                    settingsCard {
                        Toggle(isOn: $soundEnabled) {
                            Text("Sound")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .tint(.orangeDot)
                        .padding()
                        Divider()
                            .background(Color.orangeDot.opacity(0.15))
                            .padding(.leading, 20)
                        Toggle(isOn: $hapticsEnabled) {
                            Text("Haptic Feedback")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .tint(.orangeDot)
                        .padding()
                    }
                    
                    VStack(spacing: 0) {
                        SettingsRow(title: "Rate us", icon: "star.fill") { rateApp() }
                        Divider()
                            .background(Color.orangeDot.opacity(0.15))
                            .padding(.leading, 20)
                        SettingsRow(title: "Privacy", icon: "hand.raised.fill") { openURL("https://www.termsfeed.com/live/483014ea-1ff1-41f0-986d-e5a1b70f5a96") }
                        Divider()
                            .background(Color.orangeDot.opacity(0.15))
                            .padding(.leading, 20)
                        SettingsRow(title: "Terms", icon: "doc.text.fill") { openURL("https://www.termsfeed.com/live/6117344b-eccf-4f65-8bc5-4e7916801479") }
                    }
                    .background(settingsCardBackground)
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(settingsCardBackground)
            .padding(.horizontal, 24)
    }
    
    private var settingsCardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.cardGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orangeDot.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
            .shadow(color: .orangeDot.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.orangeGradient)
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}
