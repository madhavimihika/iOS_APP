//
//  TapFrenzyView.swift
//  iOS_APP
//

import SwiftUI

struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameActive = false
    @State private var timer: Timer?  // ← Changed from Combine Timer
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // Background
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    // Optional: Add your background image here
                    // Image("ss")
                    //     .resizable()
                    //     .scaledToFill()
                    //     .ignoresSafeArea()
                }
                
                Text("Time: \(timeRemaining)s")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Game active button
                Button(action: {
                    if gameActive {
                        score += 1
                    }
                }) {
                    Circle()
                        .fill(gameActive ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text(gameActive ? "Hit Me" : "Game Over")
                                .font(.title)
                                .foregroundColor(gameActive ? .yellow : .secondary)
                                .bold()
                        )
                }
                
                Text("Score: \(score)")
                    .font(.title)
                    .bold()
                
                Button(gameActive ? "Playing" : "Start Game") {
                    startGame()
                }
                .disabled(gameActive)
                .buttonStyle(.borderedProminent)
                
                // Add Home button
                Button("Home") {
                    dismiss()
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("Tap Frenzy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 10
        gameActive = true
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

#Preview {
    TapFrenzyView()
}
