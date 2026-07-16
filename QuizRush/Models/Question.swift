import Foundation

struct TriviaResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    let id = UUID()
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    // Computed property for shuffled answers
    var shuffledAnswers: [String] {
        var answers = incorrect_answers
        answers.append(correct_answer)
        return answers.shuffled()
    }
    
    enum CodingKeys: String, CodingKey {
        case question
        case correct_answer
        case incorrect_answers
    }
}
