import SwiftUI
import Combine

struct LightItUpViewLevel3: View {
    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    @AppStorage("lightItUpTotalGames") private var totalGames: Int = 0
    @AppStorage("roundDuration") private var roundDuration: Int = 60
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var timeRemaining: Int = 60
    @State private var isGameActive = false
    @State private var cancellable: AnyCancellable? = nil
    @State private var litTimer: AnyCancellable? = nil
    
    @State private var tappedCardId: UUID? = nil
    @State private var feedbackType: CardView.FeedbackType = .none
    @State private var scoreAnimation: CGFloat = 1.0
    @State private var showGameOver = false
    @State private var isNewHighScore = false
    
    @State private var lives = 3
    private let maxLives = 3
    
    private let columns = 3
    private let rows = 2
    private let totalCards = 6
    private let litWindow = 1.0
    private let levelColor: Color = .purple
    private let levelName = "Level 3"
    private let levelEmoji = "🟣"
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            gridView
            gameInfoView
            Spacer()
            controlsView
            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("Light It Up L3")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { initializeCards() }
        .onDisappear { stopGame() }
        .overlay(gameOverOverlay)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(levelEmoji) \(levelName)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(levelColor)
                Text("\(rows)×\(columns)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(0..<maxLives, id: \.self) { index in
                    Image(systemName: index < lives ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Score:")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .scaleEffect(scoreAnimation)
                    .foregroundColor(feedbackType == .correct ? .green :
                                   feedbackType == .wrong ? .red : .primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("⏱️ \(timeRemaining)s")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining <= 5 ? .red : .primary)
                Text("\(litWindow, specifier: "%.1f")s lit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var gridView: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns),
            spacing: 10
        ) {
            ForEach(cards) { card in
                CardView(
                    card: card,
                    isTapped: tappedCardId == card.id,
                    feedbackType: feedbackType,
                    levelColor: levelColor
                )
                .onTapGesture {
                    handleCardTap(card: card)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: 250)
    }
    
    private var gameInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("30-45 seconds • 6 cards (2×3)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("• 1.0 seconds to tap the lit card")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("• \(roundDuration)s round • Lives: \(lives)/\(maxLives)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("• Hard difficulty - faster reaction needed!")
                .font(.caption)
                .foregroundColor(levelColor)
            
            if feedbackType != .none {
                HStack {
                    Image(systemName: feedbackType == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(feedbackType == .correct ? .green : .red)
                    Text(feedbackType == .correct ? "Correct! +1 🎉" : "Wrong! -1 ❤️")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(feedbackType == .correct ? .green : .red)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(), value: feedbackType)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var controlsView: some View {
        VStack(spacing: 12) {
            Button(action: isGameActive ? endGame : startGame) {
                Text(isGameActive ? "End Game" : "Start Game")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGameActive ? Color.red : levelColor)
                    .cornerRadius(15)
            }
            
            if !isGameActive && score > 0 {
                Text("Final Score: \(score)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(levelColor)
                
                if isNewHighScore {
                    Text("🎉 NEW HIGH SCORE! 🎉")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var gameOverOverlay: some View {
        Group {
            if showGameOver {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            if lives == 0 {
                                Text("💀 GAME OVER!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("No lives remaining!")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                            } else {
                                Text("⏰ TIME'S UP!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(levelColor)
                            }
                            
                            Text("Final Score: \(score)")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("Lives Remaining: \(lives)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            if isNewHighScore {
                                Text("🎉 NEW HIGH SCORE! 🎉")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            
                            Button("Play Again") {
                                showGameOver = false
                                startGame()
                            }
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(levelColor)
                            .cornerRadius(15)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.8))
                                .shadow(radius: 20)
                        )
                        .transition(.scale.combined(with: .opacity))
                    )
            }
        }
    }
    
    private func initializeCards() {
        cards = (0..<totalCards).map { _ in Card() }
    }
    
    private func startGame() {
        guard !isGameActive else { return }
        
        score = 0
        lives = maxLives
        timeRemaining = roundDuration
        isGameActive = true
        isNewHighScore = false
        showGameOver = false
        initializeCards()
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateTimer()
            }
        
        lightUpRandomCard()
        startLitTimer()
    }
    
    private func startLitTimer() {
        litTimer = Timer.publish(every: litWindow, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                lightUpRandomCard()
            }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            endGame()
        }
    }
    
    private func lightUpRandomCard() {
        guard isGameActive else { return }
        
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        if let randomIndex = cards.indices.randomElement() {
            cards[randomIndex].isLit = true
        }
    }
    
    private func handleCardTap(card: Card) {
        guard isGameActive else { return }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            if cards[index].isLit {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    score += 1
                    scoreAnimation = 1.3
                    feedbackType = .correct
                    tappedCardId = card.id
                    cards[index].isLit = false
                }
                
                if hapticEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                
                resetFeedback()
                lightUpRandomCard()
                
            } else {
                lives -= 1
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scoreAnimation = 0.8
                    feedbackType = .wrong
                    tappedCardId = card.id
                }
                
                if hapticEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                
                resetFeedback()
                
                if lives <= 0 {
                    endGame()
                }
            }
        }
    }
    
    private func resetFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scoreAnimation = 1.0
                tappedCardId = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                feedbackType = .none
            }
        }
    }
    
    private func endGame() {
        isGameActive = false
        cancellable?.cancel()
        litTimer?.cancel()
        cancellable = nil
        litTimer = nil
        feedbackType = .none
        
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        totalGames += 1
        if score > highScore {
            highScore = score
            isNewHighScore = true
        }
        
        withAnimation {
            showGameOver = true
        }
    }
    
    private func stopGame() {
        cancellable?.cancel()
        litTimer?.cancel()
        cancellable = nil
        litTimer = nil
        isGameActive = false
        feedbackType = .none
    }
}

#Preview {
    NavigationStack {
        LightItUpViewLevel3()
    }
}
