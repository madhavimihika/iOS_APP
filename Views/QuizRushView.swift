//
//  QuizRushView.swift
//  iOS_APP
//

import SwiftUI

// MARK: - Main Quiz Rush View
struct QuizRushView: View {
    @StateObject private var viewModel = TriviaViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                Group {
                    switch viewModel.viewState {
                    case .idle:
                        WelcomeView(viewModel: viewModel)
                        
                    case .loading:
                        LoadingView()
                        
                    case .loaded:
                        if viewModel.isGameComplete {
                            ResultsView(
                                viewModel: viewModel,
                                onPlayAgain: {
                                    viewModel.restartGame()
                                    Task { await viewModel.loadQuestions() }
                                }
                            )
                        } else if let question = viewModel.currentQuestion {
                            QuestionView(
                                viewModel: viewModel,
                                question: question
                            )
                        }
                        
                    case .failed(let message):
                        ErrorView(
                            message: message,
                            retryAction: {
                                Task { await viewModel.retryLoad() }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Quiz Rush")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Home") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if case .loaded = viewModel.viewState {
                        HStack(spacing: 12) {
                            if viewModel.streak > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("\(viewModel.streak)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                }
                            }
                            Text("Score: \(viewModel.score)")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
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
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @ObservedObject var viewModel: TriviaViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Quiz Rush")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("10 trivia questions - How many can you get right?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task { await viewModel.loadQuestions() }
            }) {
                Label("Start Quiz", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                    .onAppear { rotation = 360 }
                
                Image(systemName: "brain")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 10) {
                Text("Loading Questions...")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("From Open Trivia DB")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Question View
struct QuestionView: View {
    @ObservedObject var viewModel: TriviaViewModel
    let question: Question
    
    private var shuffledAnswers: [String] {
        question.shuffledAnswers
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(viewModel.currentIndex + 1) of \(viewModel.totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if viewModel.streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(viewModel.streak)x")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("Score: \(viewModel.score)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: viewModel.progress)
                    .tint(.blue)
            }
            .padding(.horizontal)
            
            // Question Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(question.category)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Text(question.difficulty.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(difficultyColor(question.difficulty))
                        .cornerRadius(6)
                }
                
                Text(question.decodedQuestion)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.horizontal)
            
            // Answer Buttons
            VStack(spacing: 12) {
                ForEach(shuffledAnswers, id: \.self) { answer in
                    AnswerButton(
                        answer: answer,
                        isSelected: viewModel.selectedAnswer == answer,
                        isCorrect: answer == question.decodedCorrectAnswer,
                        showResult: viewModel.showResult,
                        action: {
                            viewModel.selectAnswer(answer)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Next Button
            if viewModel.showResult {
                Button(action: {
                    viewModel.nextQuestion()
                }) {
                    HStack {
                        Text(viewModel.isGameComplete ? " See Results" : "Next Question ➜")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isGameComplete ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: (viewModel.isGameComplete ? Color.green : Color.blue).opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("👆 Tap an answer above")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .padding(.vertical)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showResult)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy": return Color.green.opacity(0.3)
        case "medium": return Color.orange.opacity(0.3)
        case "hard": return Color.red.opacity(0.3)
        default: return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Answer Button
struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(answer)
                .font(.body)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(showResult)
    }
    
    private var backgroundColor: Color {
        if !showResult {
            return isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6)
        }
        if isCorrect { return Color.green.opacity(0.2) }
        if isSelected && !isCorrect { return Color.red.opacity(0.2) }
        return Color(.systemGray6)
    }
    
    private var textColor: Color {
        if !showResult { return isSelected ? .blue : .primary }
        if isCorrect { return .green }
        if isSelected && !isCorrect { return .red }
        return .secondary
    }
    
    private var borderColor: Color {
        if !showResult { return isSelected ? Color.blue : Color.clear }
        if isCorrect { return Color.green }
        if isSelected && !isCorrect { return Color.red }
        return Color.clear
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Oops! Something went wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Results View
struct ResultsView: View {
    let viewModel: TriviaViewModel
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: resultIcon)
                .font(.system(size: 80))
                .foregroundColor(resultColor)
            
            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                Text("\(viewModel.correctCount) / \(viewModel.totalQuestions)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("\(Int((Double(viewModel.correctCount) / Double(viewModel.totalQuestions)) * 100))%")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                StatRow(label: "✅ Correct", value: "\(viewModel.correctCount)", color: .green)
                StatRow(label: "❌ Incorrect", value: "\(viewModel.wrongCount)", color: .red)
                StatRow(label: "🏆 Best Streak", value: "\(viewModel.maxStreak)", color: .orange)
                StatRow(label: "⭐ Total Score", value: "\(viewModel.score)", color: .blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Text(performanceMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: onPlayAgain) {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
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
        if percentage >= 0.9 { return "🌟 Outstanding! You're a trivia genius!" }
        if percentage >= 0.7 { return "🎯 Great job! You really know your stuff!" }
        if percentage >= 0.5 { return "📚 Good effort! Keep learning!" }
        return "💪 Don't give up! Practice makes perfect!"
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview
#Preview {
    QuizRushView()
}
