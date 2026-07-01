//
//  HomeView.swift
//  iOS_APP
//

import SwiftUI

struct HomeView: View {
    @State private var selectedApp: AppType?
    
    enum AppType {
        case quizRush
        case tapFrenzy
        case lightItUp
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                        
                        Text("Mini Games")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Choose a game to play")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: QuizRushView()) {
                            AppButton(
                                title: "Quiz Rush",
                                subtitle: "10 trivia questions",
                                icon: "brain.head.profile",
                                color: .blue
                            )
                        }
                        
                        NavigationLink(destination: TapFrenzyView()) {
                            AppButton(
                                title: "Tap Frenzy",
                                subtitle: "Tap as fast as you can!",
                                icon: "hand.tap.fill",
                                color: .orange
                            )
                        }
                        
                        NavigationLink(destination: LightItUpView()) {
                            AppButton(
                                title: "Light It Up",
                                subtitle: "Tap the lights before time runs out",
                                icon: "lightbulb.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("Week 4 Assessment - All 3 apps working!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Reusable App Button
struct AppButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
}
