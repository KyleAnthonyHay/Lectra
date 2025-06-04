import SwiftUI

enum CardAnimationPhase: CaseIterable {
    case initial
    case cardAppear
    case headerAppear
    case subtextAppear
    case buttonAppear
    case final
    
    var offset: CGFloat {
        switch self {
        case .initial:
            return 20
        case .cardAppear:
            return 10
        case .headerAppear, .subtextAppear, .buttonAppear, .final:
            return 0
        }
    }
    
    var opacity: Double {
        switch self {
        case .initial:
            return 0
        case .cardAppear:
            return 0.5
        case .headerAppear, .subtextAppear, .buttonAppear, .final:
            return 1
        }
    }
    
    var animation: Animation {
        switch self {
        case .initial:
            return .easeOut(duration: 0.0)
        case .cardAppear:
            return .easeOut(duration: 0.5)
        case .headerAppear:
            return .easeOut(duration: 0.3).delay(0.2)
        case .subtextAppear:
            return .easeOut(duration: 0.3).delay(0.3)
        case .buttonAppear:
            return .easeOut(duration: 0.3).delay(0.4)
        case .final:
            return .easeOut(duration: 0.2)
        }
    }
}

struct CardAnimationModifier: ViewModifier {
    let phase: CardAnimationPhase
    let elementType: CardElement
    
    enum CardElement {
        case card
        case header
        case subtext
        case button
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(shouldBeVisible ? phase.opacity : 0)
            .offset(y: shouldBeVisible ? phase.offset : 20)
    }
    
    private var shouldBeVisible: Bool {
        switch elementType {
        case .card:
            return phase != .initial
        case .header:
            return phase == .headerAppear || phase == .subtextAppear || phase == .buttonAppear || phase == .final
        case .subtext:
            return phase == .subtextAppear || phase == .buttonAppear || phase == .final
        case .button:
            return phase == .buttonAppear || phase == .final
        }
    }
}

extension View {
    func cardAnimation(_ phase: CardAnimationPhase, for element: CardAnimationModifier.CardElement) -> some View {
        modifier(CardAnimationModifier(phase: phase, elementType: element))
    }
} 