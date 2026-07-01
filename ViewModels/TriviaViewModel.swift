//
//  TriviaViewModel.swift
//  iOS_APP
//

import Foundation
import SwiftUI
import Combine

// MARK: - View State
enum ViewState {
    case idle
    case loading
    case loaded([Question])
    case failed(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
    
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    var questions: [Question] {
        if case .loaded(let q) = self { return q }
        return []
    }
}

// MARK: - Answer Feedback
enum AnswerFeedback {
    case correct(bonus: Int)
    case wrong(correctAnswer: String)
}

// MARK: - Trivia ViewModel
@MainActor
class TriviaViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var correctCount: Int = 0
    @Published private(set) var wrongCount: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var maxStreak: Int = 0
    @Published private(set) var selectedAnswer: String?
    @Published private(set) var showResult: Bool = false
    @Published private(set) var answerFeedback: AnswerFeedback?
    
    @Published var questionAmount: Int = 10
    @Published var selectedDifficulty: String = "any"
    
    // Mrivate
    private let service: TriviaService
    private var questions: [Question] = []
    private var isLoading: Bool = false
    
    // Computed Properties
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var totalQuestions: Int {
        questions.count
    }
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }
    
    var isGameComplete: Bool {
        currentIndex >= totalQuestions && totalQuestions > 0
    }
    
    // init
    init(service: TriviaService = TriviaService()) {
        self.service = service
        print("📱 TriviaViewModel initialized")
    }
    
    // Load Questions (API with Local Fallback)
    func loadQuestions() async {
        guard !isLoading else {
            print("Already loading, skipping...")
            return
        }
        
        print("Loading questions...")
        resetGame()
        viewState = .loading
        isLoading = true
        
        let fetchedQuestions = await service.fetchQuestionsWithFallback(amount: questionAmount)
        isLoading = false
        
        if fetchedQuestions.isEmpty {
            print(" No questions available")
            viewState = .failed("No questions available. Please try again.")
        } else {
            print(" Loaded \(fetchedQuestions.count) questions")
            self.questions = fetchedQuestions
            viewState = .loaded(fetchedQuestions)
        }
    }
    
    // Select Answer
    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion,
              selectedAnswer == nil else { return }
        
        print("Selected answer: \(answer)")
        selectedAnswer = answer
        showResult = true
        
        if answer == question.decodedCorrectAnswer {
            streak += 1
            correctCount += 1
            let bonus = calculateBonus()
            score += 1 + bonus
            answerFeedback = .correct(bonus: bonus)
            print("Correct! Score: \(score), Correct: \(correctCount), Bonus: +\(bonus)")
        } else {
            streak = 0
            wrongCount += 1
            score = max(0, score - 1)
            answerFeedback = .wrong(correctAnswer: question.decodedCorrectAnswer)
            print("Wrong! Score: \(score), Wrong: \(wrongCount)")
        }
        
        if streak > maxStreak {
            maxStreak = streak
            print("New max streak: \(maxStreak)")
        }
        
        objectWillChange.send()
    }
    
    // Next Question
    func nextQuestion() {
        guard currentIndex < totalQuestions - 1 else {
            print("Game complete!")
            currentIndex = totalQuestions
            showResult = false
            selectedAnswer = nil
            objectWillChange.send()
            return
        }
        
        currentIndex += 1
        selectedAnswer = nil
        showResult = false
        answerFeedback = nil
        print("Moving to question \(currentIndex + 1)")
        objectWillChange.send()
    }
    
    // Restart Game
    func restartGame() {
        print(" Restarting game")
        currentIndex = 0
        score = 0
        correctCount = 0
        wrongCount = 0
        streak = 0
        maxStreak = 0
        selectedAnswer = nil
        showResult = false
        answerFeedback = nil
    }
    
    // MARK: - Reset Game
    func resetGame() {
        print(" Full reset")
        questions = []
        currentIndex = 0
        score = 0
        correctCount = 0
        wrongCount = 0
        streak = 0
        maxStreak = 0
        selectedAnswer = nil
        showResult = false
        answerFeedback = nil
        viewState = .idle
    }
    
    // MARK: - Retry
    func retryLoad() async {
        print("Retrying load.")
        await loadQuestions()
    }
    
    // MARK: - Private Helpers
    private func calculateBonus() -> Int {
        switch streak {
        case 0...2: return 0
        case 3...5: return 1
        case 6...9: return 2
        case 10...: return 3
        default: return 0
        }
    }
}
