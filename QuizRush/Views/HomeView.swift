import SwiftUI
//import UIKit

struct HomeView: View {
    @State private var selectedMode: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Quiz Rush")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 20) {
                    NavigationLink(destination: QuizRushView()) {
                        ModeCard(
                            title: "Quiz Rush",
                            subtitle: "Live Trivia Challenge",
                            icon: "brain.head.profile",
                            color: .blue
                        )
                    }
                    
                    ModeCard(
                        title: "Tap Frenzy",
                        subtitle: "Coming Soon",
                        icon: "hand.tap.fill",
                        color: .green,
                        isEnabled: false
                    )
                    
                    ModeCard(
                        title: "Light It Up",
                        subtitle: "Coming Soon",
                        icon: "lightbulb.fill",
                        color: .orange,
                        isEnabled: false
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct ModeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isEnabled: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .opacity(isEnabled ? 1 : 0.3)
        }
        .padding()
//        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity(isEnabled ? 1 : 0.6)
        .disabled(!isEnabled)
    }
}
