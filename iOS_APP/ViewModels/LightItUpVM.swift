import SwiftUI
import Combine

// MARK: - Card Model
struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}

// MARK: - Level Configuration
enum GameLevel: CaseIterable {
    case l1, l2, l3, l4
    
    var displayName: String {
        switch self {
        case .l1: return "Level 1"
        case .l2: return "Level 2"
        case .l3: return "Level 3"
        case .l4: return "Level 4"
        }
    }
    
    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }
    
    var rows: Int {
        switch self {
        case .l1: return 1
        case .l2: return 1
        case .l3: return 2
        case .l4: return 3
        }
    }
    
    var totalCards: Int {
        return rows * columns
    }
    
    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }
    
    var cardsToLight: Int {
        switch self {
        case .l1, .l2, .l3: return 1
        case .l4: return 2      // 2 cards light up at once!
        }
    }
    
    var color: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .purple
        case .l4: return .red
        }
    }
    
    var emoji: String {
        switch self {
        case .l1: return "🟢"
        case .l2: return "🔵"
        case .l3: return "🟣"
        case .l4: return "🔴"
        }
    }
    
    var timeRange: String {
        switch self {
        case .l1: return "0-15s"
        case .l2: return "15-30s"
        case .l3: return "30-45s"
        case .l4: return "45-60s"
        }
    }
}

// MARK: - LightUp ViewModel
class LightUpVM: ObservableObject {
    // MARK: - Published Properties
    @Published var cards: [Card] = []
    @Published var score = 0
    @Published var timeRemaining: Int = 60
    @Published var isGameActive = false
    @Published var currentLevel: GameLevel = .l1
    @Published var tappedCardId: UUID? = nil
    @Published var feedbackType: CardView.FeedbackType = .none
    @Published var scoreAnimation: CGFloat = 1.0
    @Published var showLevelUp = false
    @Published var showGameOver = false
    @Published var isNewHighScore = false
    @Published var lives = 3
    
    // MARK: - AppStorage Properties
    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    @AppStorage("lightItUpTotalGames") private var totalGames: Int = 0
    @AppStorage("roundDuration") var roundDuration: Int = 60
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true
    
    // MARK: - Constants
    let maxLives = 3
    
    // MARK: - Private Properties
    private var cancellable: AnyCancellable? = nil
    private var litTimer: AnyCancellable? = nil
    
    // MARK: - Level Progression Helper
    private func getLevelForTime(_ elapsedTime: Int) -> GameLevel {
        switch elapsedTime {
        case 0..<15: return .l1
        case 15..<30: return .l2
        case 30..<45: return .l3
        default: return .l4
        }
    }
    
    // MARK: - Public Methods
    
    func initializeCards() {
        cards = (0..<currentLevel.totalCards).map { _ in Card() }
    }
    
    func startGame() {
        guard !isGameActive else { return }
        
        score = 0
        lives = maxLives
        timeRemaining = roundDuration
        isGameActive = true
        currentLevel = .l1
        isNewHighScore = false
        showGameOver = false
        showLevelUp = false
        initializeCards()
        
        // Countdown timer
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateTimer()
            }
        
        lightUpRandomCards()
        startLitTimer()
    }
    
    func stopGame() {
        cancellable?.cancel()
        litTimer?.cancel()
        cancellable = nil
        litTimer = nil
        isGameActive = false
        feedbackType = .none
    }
    
    func endGame() {
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
    
    func handleCardTap(card: Card) {
        guard isGameActive else { return }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            if cards[index].isLit {
                //  Correct tap
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
                
                // Check if all lit cards have been tapped
                let remainingLitCards = cards.filter { $0.isLit }.count
                if remainingLitCards == 0 {
                    lightUpRandomCards()
                }
                
            } else {
                //  Wrong tap-lose a life
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
    
    // Private Methods
    
    private func startLitTimer() {
        litTimer = Timer.publish(every: currentLevel.litWindow, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.lightUpRandomCards()
            }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            updateLevel()
        } else {
            endGame()
        }
    }
    
    private func updateLevel() {
        let elapsedTime = roundDuration - timeRemaining
        let newLevel = getLevelForTime(elapsedTime)
        
        if newLevel != currentLevel {
            withAnimation {
                showLevelUp = true
            }
            currentLevel = newLevel
            initializeCards()
            litTimer?.cancel()
            lightUpRandomCards()
            startLitTimer()
            
            // Auto-dismiss level up after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.showLevelUp = false
                }
            }
        }
    }
    
    private func lightUpRandomCards() {
        guard isGameActive else { return }
        
        // Turn off all cards
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        // Light up random cards
        let shuffledIndices = cards.indices.shuffled()
        let selectedIndices = shuffledIndices.prefix(currentLevel.cardsToLight)
        
        for index in selectedIndices {
            cards[index].isLit = true
        }
    }
    
    private func resetFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.scoreAnimation = 1.0
                self.tappedCardId = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                self.feedbackType = .none
            }
        }
    }
}
