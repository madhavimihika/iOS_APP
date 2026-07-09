import SwiftUI

struct CardView: View {
    let card: Card
    let isTapped: Bool
    let feedbackType: FeedbackType
    let levelColor: Color
    
    enum FeedbackType {
        case none, correct, wrong
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(backgroundColor)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: isTapped ? 4 : 2)
            )
            .scaleEffect(scaleEffect)
            .shadow(color: shadowColor, radius: shadowRadius)
            .overlay(feedbackOverlay)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isLit)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTapped)
    }
    
    private var backgroundColor: Color {
        if card.isLit {
            // Hex: FB7185 -
            return Color(red: 251/255, green: 113/255, blue: 133/255)
        } else if isTapped && feedbackType == .wrong {
            return .red.opacity(0.2)
        } else {
            return .white.opacity(0.04)
        }
    }
    
    private var borderColor: Color {
        if card.isLit {
            // Hex: F43F5E -
            return Color(red: 244/255, green: 63/255, blue: 94/255)
        } else if isTapped && feedbackType == .correct {
            return .green
        } else if isTapped && feedbackType == .wrong {
            return .red
        } else {
            return .white.opacity(0.1)
        }
    }
    
    private var scaleEffect: CGFloat {
        if card.isLit {
            return 1.04
        } else if isTapped {
            return 0.96
        } else {
            return 1.0
        }
    }
    
    private var shadowColor: Color {
        if card.isLit {
            // F43F5E -> RGB
            return Color(red: 244/255, green: 63/255, blue: 94/255).opacity(0.4)
        } else if isTapped && feedbackType == .correct {
            return .green.opacity(0.4)
        } else if isTapped && feedbackType == .wrong {
            return .red.opacity(0.4)
        } else {
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        return (card.isLit || isTapped) ? 12 : 0
    }
    
    @ViewBuilder
    private var feedbackOverlay: some View {
        if isTapped && feedbackType != .none {
            Image(systemName: feedbackType == .correct ? "checkmark" : "xmark")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(feedbackType == .correct ? .green : .red)
                .transition(.scale.combined(with: .opacity))
        }
    }
}
