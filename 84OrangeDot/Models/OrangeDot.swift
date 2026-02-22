//
//  OrangeDot.swift
//  84OrangeDot
//

import Foundation
import CoreGraphics

struct OrangeDot: Identifiable, Equatable {
    let id = UUID()
    var type: DotType
    var position: CGPoint
    var size: DotSize
    var appearanceTime: Date
    var lifetime: TimeInterval
    var state: DotState = .appearing
    var movement: DotMovement?
    var behavior: DotBehavior
    
    enum DotType: Equatable {
        case regular
        case lifeBonus
        case timeBonus
        case scoreBonus
    }
    
    enum DotSize: CGFloat, CaseIterable {
        case tiny = 10
        case small = 20
        case medium = 40
        case large = 60
        
        var points: Int {
            switch self {
            case .tiny: return 100
            case .small: return 50
            case .medium: return 25
            case .large: return 10
            }
        }
        
        var displayTime: TimeInterval {
            switch self {
            case .tiny: return 0.3
            case .small: return 0.5
            case .medium: return 1.0
            case .large: return 2.0
            }
        }
    }
    
    enum DotState: Equatable {
        case appearing, visible, disappearing, tapped
    }
    
    enum DotBehavior: Equatable {
        case `static`
        case moving
        case pulsing
        case fading
        case splitting
    }
    
    struct DotMovement: Equatable {
        var velocity: CGPoint
        var direction: CGFloat
    }
}
