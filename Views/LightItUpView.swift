//
//  LightItUpView.swift
//  iOS_APP
//

import SwiftUI

struct LightItUpView: View {
    @State private var lights: [Bool] = Array(repeating: false, count: 9)
    @State private var score = 0
    @State private var timeRemaining = 15
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                if !isRunning && timeRemaining == 15 {
                    VStack(spacing: 25) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)
                        
                        Text("Light It Up")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tap the lights before time runs out!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Start Game") {
                            startGame()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                } else {
                    VStack(spacing: 20) {
                        HStack {
                            VStack {
                                Text("Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(score)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
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
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                            ForEach(0..<9, id: \.self) { index in
                                Button {
                                    if isRunning && lights[index] {
                                        lights[index] = false
                                        score += 1
                                    }
                                } label: {
                                    Circle()
                                        .fill(lights[index] ? Color.purple : Color.gray.opacity(0.3))
                                        .frame(height: 80)
                                        .shadow(radius: lights[index] ? 10 : 0)
                                        .scaleEffect(lights[index] ? 1.0 : 0.9)
                                        .animation(.spring(response: 0.3), value: lights[index])
                                }
                                .disabled(!isRunning || !lights[index])
                            }
                        }
                        .padding()
                        
                        if !isRunning && timeRemaining < 15 {
                            Button("Play Again") {
                                resetGame()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Light It Up")
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
        timeRemaining = 15
        isRunning = true
        lights = Array(repeating: false, count: 9)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            spawnLight()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            spawnLight()
        }
    }
    
    func spawnLight() {
        guard isRunning else { return }
        
        lights = Array(repeating: false, count: 9)
        let count = Int.random(in: 1...3)
        var indices = Array(0..<9).shuffled()
        for i in 0..<min(count, indices.count) {
            lights[indices[i]] = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if isRunning {
                lights = Array(repeating: false, count: 9)
            }
        }
    }
    
    func endGame() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
        lights = Array(repeating: false, count: 9)
    }
    
    func resetGame() {
        score = 0
        timeRemaining = 15
        isRunning = false
        lights = Array(repeating: false, count: 9)
        timer?.invalidate()
        timer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
}

#Preview {
    LightItUpView()
}
