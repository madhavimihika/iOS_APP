//
//  TapFrenzyView.swift
//  iOS_APP
//

import SwiftUI

struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isRunning = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if !isRunning && timeRemaining == 10 {
                    VStack(spacing: 25) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text("Tap Frenzy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tap as fast as you can in 10 seconds!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Start Game") {
                            startGame()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                } else {
                    VStack(spacing: 25) {
                        HStack {
                            VStack {
                                Text("Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(score)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(timeRemaining)s")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(timeRemaining <= 3 ? .red : .primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Button {
                            if isRunning {
                                score += 1
                            }
                        } label: {
                            Circle()
                                .fill(isRunning ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 200, height: 200)
                                .overlay(
                                    VStack {
                                        if isRunning {
                                            Image(systemName: "hand.tap.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.white)
                                            Text("TAP!")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        } else {
                                            Text("Game Over")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                )
                                .shadow(radius: 10)
                                .scaleEffect(isRunning ? 1.0 : 0.95)
                                .animation(.spring(response: 0.3), value: isRunning)
                        }
                        .disabled(!isRunning)
                        
                        Spacer()
                        
                        if !isRunning && timeRemaining < 10 {
                            Button("Play Again") {
                                resetGame()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Tap Frenzy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Home") { dismiss() }
                }
            }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 10
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    func endGame() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetGame() {
        score = 0
        timeRemaining = 10
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    TapFrenzyView()
}
