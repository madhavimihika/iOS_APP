import Foundation
import Combine

class QuizRushVM: ObservableObject {
    // MARK: - Published Properties
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var correctCount = 0
    @Published var wrongCount = 0
    @Published var streak = 0
    @Published var maxStreak = 0
    @Published var selectedAnswer: String?
    @Published var showResult = false
    @Published var isGameComplete = false
    @Published var viewState: ViewState = .idle
    @Published var progress: Double = 0
    
    var totalQuestions: Int {
        questions.count
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    enum ViewState {
        case idle
        case loading
        case loaded
        case failed(String)
    }
    
    //public Methods
    @MainActor
    func loadQuestions() async {
        viewState = .loading
        
        do {
            let fetchedQuestions = try await TriviaService.shared.fetchQuestions()
            questions = fetchedQuestions
            currentIndex = 0
            score = 0
            correctCount = 0
            wrongCount = 0
            streak = 0
            maxStreak = 0
            selectedAnswer = nil
            showResult = false
            isGameComplete = false
            viewState = .loaded
            updateProgress()
        } catch {
            viewState = .failed(error.localizedDescription)
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard !showResult, let question = currentQuestion else { return }
        
        selectedAnswer = answer
        showResult = true
        
        let isCorrect = answer == question.correctAnswer  // ← No decoding
        
        if isCorrect {
            correctCount += 1
            score += 10
            streak += 1
            if streak > maxStreak {
                maxStreak = streak
            }
        } else {
            wrongCount += 1
            streak = 0
        }
    }
    
    func nextQuestion() {
        guard showResult else { return }
        
        currentIndex += 1
        selectedAnswer = nil
        showResult = false
        updateProgress()
        
        if currentIndex >= questions.count {
            isGameComplete = true
        }
    }
    
    func restartGame() {
        currentIndex = 0
        score = 0
        correctCount = 0
        wrongCount = 0
        streak = 0
        maxStreak = 0
        selectedAnswer = nil
        showResult = false
        isGameComplete = false
        updateProgress()
    }
    
    @MainActor
    func retryLoad() async {
        await loadQuestions()
    }
    
    // MARK: - Private Methods
    private func updateProgress() {
        guard totalQuestions > 0 else { return }
        progress = Double(currentIndex) / Double(totalQuestions)
    }
}

// Question Model
struct Question: Codable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    var shuffledAnswers: [String] {
        var all = incorrectAnswers
        all.append(correctAnswer)
        return all.shuffled()
    }
}
