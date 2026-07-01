//
//  TriviaModels.swift
//  iOS_APP
//

import Foundation

// MARK: - API Response
struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [Question]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

// MARK: - Question Model
struct Question: Codable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    // Computed Properties
    var decodedQuestion: String {
        question.htmlDecoded
    }
    
    var decodedCorrectAnswer: String {
        correctAnswer.htmlDecoded
    }
    
    var shuffledAnswers: [String] {
        let all = incorrectAnswers.map { $0.htmlDecoded } + [decodedCorrectAnswer]
        return all.shuffled()
    }
}

// MARK: - HTML Decoder (Pure Swift - No UIKit)
extension String {
    var htmlDecoded: String {
        var decoded = self
        
        // Common HTML entities
        let replacements: [String: String] = [
            "&quot;": "\"",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&apos;": "'",
            "&#039;": "'",
            "&rsquo;": "'",
            "&lsquo;": "'",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&ndash;": "-",
            "&mdash;": "-",
            "&nbsp;": " ",
            "&eacute;": "é",
            "&Eacute;": "É",
            "&auml;": "ä",
            "&ouml;": "ö",
            "&uuml;": "ü",
            "&ccedil;": "ç",
            "&deg;": "°",
            "&reg;": "®",
            "&copy;": "©",
            "&trade;": "™",
            "&hellip;": "…",
            "&laquo;": "«",
            "&raquo;": "»",
            "&frac12;": "½",
            "&frac14;": "¼",
            "&frac34;": "¾"
        ]
        
        for (key, value) in replacements {
            decoded = decoded.replacingOccurrences(of: key, with: value)
        }
        
        return decoded
    }
}
