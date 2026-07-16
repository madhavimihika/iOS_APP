import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if case .loaded = viewModel.state {
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(viewModel.score)")
                                .font(.headline)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(viewModel.streak)")
                                .font(.headline)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            // Main Content
            Group {
                switch viewModel.state {
                case .idle:
                    idleView
                case .loading:
                    loadingView
                case .loaded:
                    if let question = viewModel.currentQuestion {
                        questionView(question)
                    }
                case .failed(let error):
                    errorView(error)
                case .finished:
                    resultView
                }
            }
            
            Spacer()
        }
        .task {
            await viewModel.loadQuestions()
        }
    }
    
    var idleView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Ready to play?")
                .font(.title2)
            ProgressView()
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading questions...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Oops! Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await viewModel.loadQuestions()
                }
            }) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    func questionView(_ question: Question) -> some View {
        VStack(spacing: 24) {
            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text(viewModel.progressText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if viewModel.streak >= 3 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("🔥 Streak x\(viewModel.streak)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                ProgressView(value: viewModel.progress)
                    .tint(.blue)
                    .animation(.easeInOut, value: viewModel.progress)
            }
            
            // Question
            VStack(spacing: 12) {
                Text("Question \(viewModel.currentIndex + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Answers
            VStack(spacing: 12) {
                ForEach(question.shuffledAnswers, id: \.self) { answer in
                    QuizAnswerButton(
                        answer: answer,
                        isSelected: viewModel.selectedAnswer == answer,
                        answerState: viewModel.answerState,
                        isCorrect: answer == question.correct_answer,
                        isLocked: viewModel.isAnswerLocked
                    ) {
                        viewModel.selectAnswer(answer)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var resultView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Quiz Complete! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                QuizResultStat(label: "Final Score", value: "\(viewModel.score)", icon: "star.fill")
                QuizResultStat(label: "Best Streak", value: "\(viewModel.maxStreak)", icon: "flame.fill")
                QuizResultStat(label: "Questions Answered", value: "\(viewModel.questions.count)", icon: "checkmark.circle.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            HStack(spacing: 20) {
                Button(action: {
                    Task {
                        await viewModel.loadQuestions()
                    }
                }) {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Label("Home", systemImage: "house.fill")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views for QuizRushView

struct QuizAnswerButton: View {
    let answer: String
    let isSelected: Bool
    let answerState: AnswerState
    let isCorrect: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            guard !isLocked else { return }
            action()
        }) {
            Text(answer)
                .font(.body)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
                .scaleEffect(isSelected && answerState != .none ? 0.98 : 1.0)
                .animation(.spring(response: 0.3), value: isSelected)
                .animation(.spring(response: 0.3), value: answerState)
        }
        .disabled(isLocked)
    }
    
    var backgroundColor: Color {
        guard isLocked else {
            return isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15)
        }
        
        if isCorrect {
            return Color.green.opacity(0.3)
        } else if isSelected && !isCorrect {
            return Color.red.opacity(0.3)
        }
        return Color.gray.opacity(0.15)
    }
    
    var borderColor: Color {
        guard isLocked else {
            return isSelected ? Color.blue : Color.clear
        }
        
        if isCorrect {
            return Color.green
        } else if isSelected && !isCorrect {
            return Color.red
        }
        return Color.clear
    }
    
    var textColor: Color {
        guard isLocked else {
            return .primary
        }
        
        if isCorrect {
            return .green
        } else if isSelected && !isCorrect {
            return .red
        }
        return .primary
    }
}

struct QuizResultStat: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
