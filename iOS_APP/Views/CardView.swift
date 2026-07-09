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
        RoundedRectangle(cornerRadius: 15)
            .fill(backgroundColor)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(borderColor, lineWidth: isTapped ? 4 : 3)
            )
            .scaleEffect(scaleEffect)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTapped)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isLit)
            .shadow(color: shadowColor, radius: shadowRadius)
            .overlay(feedbackOverlay)
    }
    
    private var backgroundColor: Color {
        if card.isLit {
            return .yellow
        } else if isTapped && feedbackType == .wrong {
            return .red.opacity(0.3)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var borderColor: Color {
        if card.isLit {
            return levelColor
        } else if isTapped && feedbackType == .correct {
            return .green
        } else if isTapped && feedbackType == .wrong {
            return .red
        } else {
            return .clear
        }
    }
    
    private var scaleEffect: CGFloat {
        if card.isLit {
            return 1.05
        } else if isTapped {
            return 0.95
        } else {
            return 1.0
        }
    }
    
    private var shadowColor: Color {
        if card.isLit {
            return .yellow.opacity(0.5)
        } else if isTapped && feedbackType == .correct {
            return .green.opacity(0.5)
        } else if isTapped && feedbackType == .wrong {
            return .red.opacity(0.5)
        } else {
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        if card.isLit || isTapped {
            return 10
        } else {
            return 0
        }
    }
    
    @ViewBuilder
    private var feedbackOverlay: some View {
        if isTapped {
            Image(systemName: feedbackType == .correct ? "checkmark" : "xmark")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(feedbackType == .correct ? .green : .red)
                .transition(.scale.combined(with: .opacity))
        }
    }
}
