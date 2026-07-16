import SwiftUI
import Combine

enum QuizState {
    case idle
    case loading
    case loaded
    case failed(Error)
    case finished
}

enum AnswerState {
    case none
    case correct
    case wrong
}

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var maxStreak = 0
    @Published var state: QuizState = .idle
    @Published var answerState: AnswerState = .none
    @Published var selectedAnswer: String?
    @Published var isAnswerLocked = false
    
    private let networkService = NetworkService.shared
    
    // Add explicit initializer
    init() {
        // Initialize with default values
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }
    
    var progressText: String {
        "\(currentIndex + 1) of \(questions.count)"
    }
    
    func loadQuestions() async {
        state = .loading
        resetGame()
        
        do {
            let fetchedQuestions = try await networkService.fetchQuestions()
            questions = fetchedQuestions
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard !isAnswerLocked, let question = currentQuestion else { return }
        
        isAnswerLocked = true
        selectedAnswer = answer
        
        let isCorrect = answer == question.correct_answer
        
        withAnimation(.spring(response: 0.3)) {
            answerState = isCorrect ? .correct : .wrong
        }
        
        if isCorrect {
            streak += 1
            let bonusPoints = streak >= 3 ? streak * 2 : 1
            score += bonusPoints
            if streak > maxStreak {
                maxStreak = streak
            }
        } else {
            streak = 0
            score = max(0, score - 1)
        }
        
        // Advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.advanceToNextQuestion()
        }
    }
    
    private func advanceToNextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            isAnswerLocked = false
            selectedAnswer = nil
            answerState = .none
        } else {
            state = .finished
        }
    }
    
    func resetGame() {
        currentIndex = 0
        score = 0
        streak = 0
        maxStreak = 0
        isAnswerLocked = false
        selectedAnswer = nil
        answerState = .none
    }
    
    func retry() {
        Task {
            await loadQuestions()
        }
    }
}
