//
//  Color+Hex.swift
//  84OrangeDot
//

import SwiftUI

extension Color {
    static let orangeDot = Color(hex: "FF3C00")
    static let orangeDotLight = Color(hex: "FF6B3D")
    static let orangeDotDark = Color(hex: "E03500")
    static let warmWhite = Color(hex: "FFF9F7")
    static let warmGray = Color(hex: "F5F0ED")
    
    // MARK: - Gradients
    
    static var orangeGradient: LinearGradient {
        LinearGradient(
            colors: [.orangeDotLight, .orangeDot],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var orangeGradientVertical: LinearGradient {
        LinearGradient(
            colors: [.orangeDotLight, .orangeDot, .orangeDotDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var screenBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [.warmWhite, .white, .warmGray.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [.white, .warmWhite.opacity(0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var orangeGlowGradient: RadialGradient {
        RadialGradient(
            colors: [.orangeDot.opacity(0.5), .orangeDot.opacity(0.2), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
