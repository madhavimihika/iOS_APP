import SwiftUI
internal import _LocationEssentials

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushVM()
    @StateObject private var statsVM = StatsVM()
    @StateObject private var locationService = LocationService()
    @Environment(\.dismiss) private var dismiss
    @State private var hasLoaded = false
    @State private var gameEnded = false
    
   
    private let primaryGradient = LinearGradient(
        colors: [Color(hex: "FB7185"), Color(hex: "F43F5E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                LinearGradient(
                    colors: [Color(hex: "1E1114"), Color(hex: "0F172A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Group {
                    switch viewModel.viewState {
                    case .idle:
                        WelcomeView(viewModel: viewModel, gradient: primaryGradient)
                        
                    case .loading:
                        LoadingView()
                        
                    case .loaded:
                        if viewModel.isGameComplete {
                            ResultsView(
                                viewModel: viewModel,
                                gradient: primaryGradient,
                                onPlayAgain: {
                                    viewModel.restartGame()
                                    Task { await viewModel.loadQuestions() }
                                    gameEnded = false
                                }
                            )
                            .onAppear {
                                if !gameEnded {
                                    gameEnded = true
                                    saveGameResult()
                                }
                            }
                        } else if let question = viewModel.currentQuestion {
                            QuestionView(
                                viewModel: viewModel,
                                question: question,
                                gradient: primaryGradient
                            )
                        }
                        
                    case .failed(let message):
                        ErrorView(
                            message: message,
                            gradient: primaryGradient,
                            retryAction: {
                                Task { await viewModel.retryLoad() }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Quiz Rush")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Home") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if case .loaded = viewModel.viewState {
                        HStack(spacing: 12) {
                            if viewModel.streak > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Color(hex: "FB7185"))
                                    Text("\(viewModel.streak)")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "FB7185"))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "FB7185").opacity(0.15))
                                .cornerRadius(8)
                            }
                            Text("Score: \(viewModel.score)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .task {
            if !hasLoaded, case .idle = viewModel.viewState {
                hasLoaded = true
                await viewModel.loadQuestions()
            }
        }
        .onAppear {
            locationService.requestPermission()
        }
    }
    
    func saveGameResult() {
        let location = locationService.getLocation()
        let latitude = location?.latitude ?? 0.0
        let longitude = location?.longitude ?? 0.0
        
        print("📍 Location from service: \(String(describing: location))")
        
        let session = GameSession(
            mode: .quiz,
            score: viewModel.score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        statsVM.saveSession(session)
        print(" Saved Quiz Rush Score: \(viewModel.score)")
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @ObservedObject var viewModel: QuizRushVM
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Neon Glowing Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "F43F5E").opacity(0.15))
                    .frame(width: 140, height: 140)
                    .blur(radius: 10)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(gradient)
            }
            
            VStack(spacing: 12) {
                Text("Quiz Rush")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("10 trivia questions • How many can you get right?")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: {
                Task { await viewModel.loadQuestions() }
            }) {
                Label("Start Quiz", systemImage: "play.fill")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(gradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "F43F5E").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Question View
struct QuestionView: View {
    @ObservedObject var viewModel: QuizRushVM
    let question: Question
    let gradient: LinearGradient
    
    private var shuffledAnswers: [String] {
        question.shuffledAnswers
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header stats & custom Progress Bar
            VStack(spacing: 12) {
                HStack {
                    Text("Question \(viewModel.currentIndex + 1) of \(viewModel.totalQuestions)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    if viewModel.streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                            Text("\(viewModel.streak)x Streak")
                        }
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(Color(hex: "FB7185"))
                    }
                }
                
                // Modern Soft Red Progress View
                ProgressView(value: viewModel.progress)
                    .tint(Color(hex: "F43F5E"))
                    .background(Color.white.opacity(0.1))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .cornerRadius(4)
            }
            .padding(.horizontal)
            
            // Glassmorphic Card for Question
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(question.category)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FB7185").opacity(0.15))
                        .foregroundColor(Color(hex: "FB7185"))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(question.difficulty.uppercased())
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(difficultyColor(question.difficulty))
                        .foregroundColor(difficultyTextColor(question.difficulty))
                        .cornerRadius(8)
                }
                
                Text(question.question)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
            .padding(20)
            .background(.white.opacity(0.03))
            .background(.ultraThinMaterial.opacity(0.1))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal)
            
            // Answers list
            VStack(spacing: 12) {
                ForEach(shuffledAnswers, id: \.self) { answer in
                    AnswerButton(
                        answer: answer,
                        isSelected: viewModel.selectedAnswer == answer,
                        isCorrect: answer == question.correctAnswer,
                        showResult: viewModel.showResult,
                        action: {
                            viewModel.selectAnswer(answer)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Bottom Action Button
            if viewModel.showResult {
                Button(action: {
                    viewModel.nextQuestion()
                }) {
                    Text(viewModel.isGameComplete ? "See Results" : "Next Question  ➔")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isGameComplete ? Color.green : Color(hex: "F43F5E"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: (viewModel.isGameComplete ? Color.green : Color(hex: "F43F5E")).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("👆 Tap an answer above")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 10)
            }
        }
        .padding(.vertical)
        .animation(.spring(response: 0.3), value: viewModel.showResult)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy": return Color.green.opacity(0.15)
        case "medium": return Color.orange.opacity(0.15)
        case "hard": return Color.red.opacity(0.15)
        default: return Color.gray.opacity(0.15)
        }
    }
    
    private func difficultyTextColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .gray
        }
    }
}

//Answer Button
struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(answer)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(showResult)
    }
    
    private var backgroundColor: Color {
        if !showResult {
            return isSelected ? Color(hex: "FB7185").opacity(0.15) : .white.opacity(0.04)
        }
        if isCorrect { return Color.green.opacity(0.15) }
        if isSelected && !isCorrect { return Color.red.opacity(0.15) }
        return .white.opacity(0.02)
    }
    
    private var textColor: Color {
        if !showResult { return isSelected ? Color(hex: "FB7185") : .white.opacity(0.9) }
        if isCorrect { return .green }
        if isSelected && !isCorrect { return .red }
        return .white.opacity(0.3)
    }
    
    private var borderColor: Color {
        if !showResult { return isSelected ? Color(hex: "FB7185") : .white.opacity(0.05) }
        if isCorrect { return .green }
        if isSelected && !isCorrect { return .red }
        return .clear
    }
}

//Results View
struct ResultsView: View {
    let viewModel: QuizRushVM
    let gradient: LinearGradient
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: resultIcon)
                .font(.system(size: 80))
                .foregroundColor(resultColor)
                .shadow(color: resultColor.opacity(0.3), radius: 10)
            
            Text("Quiz Complete!")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
            
            VStack(spacing: 6) {
                Text("\(viewModel.correctCount) / \(viewModel.totalQuestions)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(gradient)
                
                Text("\(Int((Double(viewModel.correctCount) / Double(viewModel.totalQuestions)) * 100))%")
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Statistics Card
            VStack(spacing: 14) {
                StatRow(label: "Correct Answers", value: "\(viewModel.correctCount)", color: .green)
                Divider().background(.white.opacity(0.1))
                StatRow(label: "Incorrect Answers", value: "\(viewModel.wrongCount)", color: .red)
                Divider().background(.white.opacity(0.1))
                StatRow(label: "Best Streak", value: "\(viewModel.maxStreak) 🔥", color: .orange)
                Divider().background(.white.opacity(0.1))
                StatRow(label: "Total Score", value: "\(viewModel.score)", color: Color(hex: "FB7185"))
            }
            .padding(20)
            .background(.white.opacity(0.04))
            .cornerRadius(18)
            .padding(.horizontal, 20)
            
            Text(performanceMessage)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: onPlayAgain) {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(gradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "F43F5E").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
        }
        .padding()
    }
    
    private var resultIcon: String {
        let percentage = Double(viewModel.correctCount) / Double(viewModel.totalQuestions)
        if percentage >= 0.9 { return "star.circle.fill" }
        if percentage >= 0.7 { return "hand.thumbsup.fill" }
        if percentage >= 0.5 { return "exclamationmark.triangle.fill" }
        return "xmark.circle.fill"
    }
    
    private var resultColor: Color {
        let percentage = Double(viewModel.correctCount) / Double(viewModel.totalQuestions)
        if percentage >= 0.9 { return .yellow }
        if percentage >= 0.7 { return .green }
        if percentage >= 0.5 { return .orange }
        return .red
    }
    
    private var performanceMessage: String {
        let percentage = Double(viewModel.correctCount) / Double(viewModel.totalQuestions)
        if percentage >= 0.9 { return "Outstanding! You're a trivia genius! 👑" }
        if percentage >= 0.7 { return "Great job! You really know your stuff! 👍" }
        if percentage >= 0.5 { return "Good effort! Keep learning! 📚" }
        return "Don't give up! Practice makes perfect! 💪"
    }
}

// Stat Row
struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// Error View
struct ErrorView: View {
    let message: String
    let gradient: LinearGradient
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Oops! Something went wrong")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(gradient)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding()
    }
}

// Loading View
struct LoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color(hex: "FB7185").opacity(0.15), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(colors: [Color(hex: "FB7185"), Color(hex: "F43F5E")], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
                Image(systemName: "brain")
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "FB7185"))
            }
            
            VStack(spacing: 10) {
                Text("Loading Questions...")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("From Open Trivia DB")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
    }
}

#Preview {
    QuizRushView()
}
