// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameActive = false
    @State private var message = ""
    @State private var showMessage = false
    @State private var timer: Timer?
    @State private var scale: CGFloat = 1.0
    
    // Button Shrinking - CONTINUOUS DECREASE
    @State private var buttonSize: CGFloat = 250
    @State private var minButtonSize: CGFloat = 80
    @State private var shrinkAmount: CGFloat = 2 // Shrink by 2 each tap
    
    // Button Movement
    @State private var buttonOffset = CGSize.zero
    @State private var moveTimer: Timer?
    @State private var moveSpeed: CGFloat = 5
    @State private var moveDirection = 1
    @State private var isMoving = false
    
    // Challenge System
    @State private var challenges: [Challenge] = []
    @State private var currentChallengeIndex = 0
    @State private var challengeProgress: Float = 0
    @State private var totalTaps = 0
    
    struct Challenge {
        let id: Int
        let title: String
        let description: String
        let requirement: ChallengeRequirement
        var isCompleted: Bool
        let reward: Int
        let icon: String
    }
    
    enum ChallengeRequirement {
        case shrinkBelow(CGFloat)
        case taps(Int)
        case score(Int)
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(hex: "0F172A"),
                    Color(hex: "1A1A3E"),
                    Color(hex: "2D1B69")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background Animation
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: 150, y: 200)
            
//            Image("Background")
//                        .resizable()
//                        .scaledToFill()
//                        .ignoresSafeArea()
//            
            
            VStack(spacing: 25) {
                // Header with Score & Timer
                HStack(spacing: 30) {
                    // Score Card
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCORE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(2)
                        
                        Text("\(score)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    // Timer Card
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("TIME")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(2)
                        
                        Text("\(timeRemaining)")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(timeRemaining <= 3 ? .red : .white)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                // Challenge Progress
                if gameActive && !challenges.isEmpty {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: challenges[currentChallengeIndex].icon)
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text(challenges[currentChallengeIndex].title)
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Spacer()
                            
                            Text("\(currentChallengeIndex + 1)/\(challenges.count)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: geometry.size.width, height: 4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(challengeProgress), height: 4)
                                    .animation(.easeInOut, value: challengeProgress)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.horizontal, 30)
                }
                
                // Status Display - Shows current size
                if gameActive {
                    HStack(spacing: 15) {
                        Text("📏 Size: \(Int(buttonSize))")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(buttonSize < 150 ? .red : .white.opacity(0.6))
                        
                        Text("👆 Taps: \(totalTaps)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        if buttonSize < 120 {
                            Text("⚠️ TINY!")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer(minLength: 20)
                
                // Message Popup
                if showMessage {
                    Text(message)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.8))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .scale(scale: 0.5).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: showMessage)
                }
                
                // Main Tap Button with Shrinking & Movement
                Button(action: handleTap) {
                    ZStack {
                        // Outer Glow - changes color based on size
                        Circle()
                            .fill(
                                buttonSize < 120 ?
                                Color.red.opacity(0.2) :
                                Color.orange.opacity(0.15)
                            )
                            .frame(width: buttonSize + 40, height: buttonSize + 40)
                            .blur(radius: 30)
                        
                        // Main Circle - color changes as it shrinks
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: buttonSize < 120 ?
                                    [Color.red, Color(hex: "DC2626")] :
                                    [Color.orange, Color(hex: "EA580C")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonSize, height: buttonSize)
                            .overlay(
                                Circle()
                                    .stroke(
                                        buttonSize < 120 ?
                                        Color.red.opacity(0.5) :
                                        Color.white.opacity(0.2),
                                        lineWidth: buttonSize < 120 ? 4 : 2
                                    )
                            )
                            .shadow(
                                color: buttonSize < 120 ?
                                Color.red.opacity(0.4) :
                                Color.orange.opacity(0.3),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                            .scaleEffect(scale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonSize)
                        
                        // Content - adjusts size with button
                        VStack(spacing: 8) {
                            if gameActive {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: min(35, buttonSize / 5)))
                                    .foregroundColor(.white)
                                
                                Text("TAP!")
                                    .font(.system(size: min(20, buttonSize / 8)))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                    .tracking(2)
                                
                                Text("\(Int(buttonSize))")
                                    .font(.system(size: min(14, buttonSize / 12)))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.7))
                            } else if timeRemaining == 0 {
                                // Game Over
                                VStack(spacing: 8) {
                                    Text("GAME OVER")
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.red)
                                        .tracking(3)
                                    
                                    Text("Final Score: \(score)")
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Final Size: \(Int(buttonSize))")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            } else {
                                // Ready State
                                VStack(spacing: 8) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    Text("READY")
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.white.opacity(0.4))
                                        .tracking(3)
                                }
                            }
                        }
                        .allowsHitTesting(false)
                    }
                }
                .disabled(!gameActive && timeRemaining > 0)
                .buttonStyle(ScaleButtonStyle())
                .padding(.vertical, 10)
                .offset(buttonOffset)
                .animation(.easeInOut(duration: 0.5), value: buttonOffset)
                
                // Warning when button is very small
                if gameActive && buttonSize < 100 {
                    Text("⚠️ BUTTON IS TINY! TAP CAREFULLY!")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .transition(.scale)
                }
                
                Spacer(minLength: 20)
                
                // Bottom Buttons
                VStack(spacing: 12) {
                    if !gameActive {
                        Button(action: startGame) {
                            HStack {
                                Image(systemName: timeRemaining == 10 ? "play.circle.fill" : "arrow.counterclockwise.circle.fill")
                                    .font(.title2)
                                Text(timeRemaining == 10 ? "START GAME" : "PLAY AGAIN")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 5)
                            .padding(.horizontal, 30)
                        }
                    }
                }
                
                // Bottom Padding
                Color.clear.frame(height: 20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupChallenges()
        }
    }
    
    // MARK: - Challenge System
    
    func setupChallenges() {
        challenges = [
            Challenge(
                id: 1,
                title: "First Shrink",
                description: "Shrink button below 230",
                requirement: .shrinkBelow(230),
                isCompleted: false,
                reward: 5,
                icon: "arrow.down.circle"
            ),
            Challenge(
                id: 2,
                title: "Speed Tapper",
                description: "Tap 10 times",
                requirement: .taps(10),
                isCompleted: false,
                reward: 10,
                icon: "hand.tap"
            ),
            Challenge(
                id: 3,
                title: "Tiny Button",
                description: "Shrink button below 180",
                requirement: .shrinkBelow(180),
                isCompleted: false,
                reward: 15,
                icon: "arrow.down.circle.fill"
            ),
            Challenge(
                id: 4,
                title: "Score Collector",
                description: "Reach 20 points",
                requirement: .score(20),
                isCompleted: false,
                reward: 20,
                icon: "star.fill"
            ),
            Challenge(
                id: 5,
                title: "Micro Button",
                description: "Shrink button below 120",
                requirement: .shrinkBelow(120),
                isCompleted: false,
                reward: 30,
                icon: "crown.fill"
            )
        ]
        currentChallengeIndex = 0
        challengeProgress = 0
    }
    
    func checkChallenges() {
        guard currentChallengeIndex < challenges.count else { return }
        let challenge = challenges[currentChallengeIndex]
        
        switch challenge.requirement {
        case .shrinkBelow(let target):
            if buttonSize <= target {
                completeChallenge(at: currentChallengeIndex)
            }
        case .taps(let target):
            if totalTaps >= target {
                completeChallenge(at: currentChallengeIndex)
            }
        case .score(let target):
            if score >= target {
                completeChallenge(at: currentChallengeIndex)
            }
        }
    }
    
    func completeChallenge(at index: Int) {
        guard index < challenges.count else { return }
        challenges[index].isCompleted = true
        let reward = challenges[index].reward
        score += reward
        
        showMessage("🏆 Challenge Complete! +\(reward)")
        
        if currentChallengeIndex < challenges.count - 1 {
            currentChallengeIndex += 1
        }
        updateChallengeProgress()
    }
    
    func updateChallengeProgress() {
        challengeProgress = Float(currentChallengeIndex) / Float(challenges.count)
    }
    
    // MARK: - Game Functions
    
    func startGame() {
        setupChallenges()
        currentChallengeIndex = 0
        challengeProgress = 0
        totalTaps = 0
        buttonSize = 250 // Reset to full size
        buttonOffset = .zero
        moveDirection = 1
        isMoving = false
        moveSpeed = 5
        
        withAnimation(.easeInOut(duration: 0.2)) {
            score = 0
            timeRemaining = 10
            gameActive = true
            message = ""
            showMessage = false
            scale = 1.0
        }
        
        // Main timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    endGame()
                }
            }
        }
        
        // Button movement timer - starts after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if gameActive {
                isMoving = true
                startMoving()
            }
        }
    }
    
    func startMoving() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if !gameActive {
                self.moveTimer?.invalidate()
                return
            }
            
            let maxOffset: CGFloat = 100
            let step = moveSpeed * CGFloat(moveDirection)
            
            withAnimation(.easeInOut(duration: 0.1)) {
                buttonOffset.width += step
                
                // Bounce off edges
                if buttonOffset.width > maxOffset {
                    buttonOffset.width = maxOffset
                    moveDirection = -1
                    buttonOffset.height = CGFloat.random(in: -50...50)
                } else if buttonOffset.width < -maxOffset {
                    buttonOffset.width = -maxOffset
                    moveDirection = 1
                    buttonOffset.height = CGFloat.random(in: -50...50)
                }
                
                // Random vertical changes
                if Int.random(in: 1...20) == 1 {
                    buttonOffset.height = CGFloat.random(in: -50...50)
                }
            }
        }
    }
    
    func handleTap() {
        guard gameActive else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        totalTaps += 1
        
        // Scale animation
        withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
            scale = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                scale = 1.0
            }
        }
        
        // Score +1 for every tap
        withAnimation(.easeInOut(duration: 0.1)) {
            score += 1
        }
        
        // CONTINUOUS SHRINKING: Button shrinks by 2 every tap
        if buttonSize > minButtonSize {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                buttonSize -= shrinkAmount
                
                // Make sure it doesn't go below minimum
                if buttonSize < minButtonSize {
                    buttonSize = minButtonSize
                }
                
                // Show message at key sizes
                if Int(buttonSize) % 20 == 0 || buttonSize < 150 {
                    showMessage("📏 Size: \(Int(buttonSize))")
                }
                
                // Increase movement speed as button shrinks
                moveSpeed = 5 + ((250 - buttonSize) / 10)
                
                // More aggressive movement when tiny
                if buttonSize < 120 {
                    // Random jolt when tiny
                    let joltX = CGFloat.random(in: -30...30)
                    let joltY = CGFloat.random(in: -30...30)
                    buttonOffset.width += joltX
                    buttonOffset.height += joltY
                    
                    // Keep within bounds
                    buttonOffset.width = min(120, max(-120, buttonOffset.width))
                    buttonOffset.height = min(100, max(-100, buttonOffset.height))
                }
            }
        } else {
            // Button is at minimum size - show warning
            showMessage("⚠️ MINIMUM SIZE!")
        }
        
        // Move button when tapped
        if isMoving {
            let randomX = CGFloat.random(in: -15...15)
            let randomY = CGFloat.random(in: -15...15)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                buttonOffset.width += randomX
                buttonOffset.height += randomY
                
                // Keep within bounds
                buttonOffset.width = min(120, max(-120, buttonOffset.width))
                buttonOffset.height = min(100, max(-100, buttonOffset.height))
            }
        }
        
        // Check challenges
        checkChallenges()
    }
    
    func endGame() {
        withAnimation(.easeInOut(duration: 0.2)) {
            gameActive = false
            isMoving = false
        }
        timer?.invalidate()
        timer = nil
        moveTimer?.invalidate()
        moveTimer = nil
    }
    
    func showMessage(_ text: String) {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
            message = text
            showMessage = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.15)) {
                showMessage = false
            }
        }
    }
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            .sRGB,
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255,
            opacity: 1
        )
    }
}

#Preview {
    ContentView()
}
